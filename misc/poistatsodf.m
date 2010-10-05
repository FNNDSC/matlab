% <header>
%   <name>
%     poistats
%   </name>
%
%   <objective>
%     Find optimal path between 2 specified points using Replica Exchange Monte Carlo algorithm
%   </objective>
%
%   <input>
%     instem, outdir, seedstem, samplestem,
%     ncontrolpoints, initsigma,
%     nsamplepoints, maskstem
%   </input>
% 
%  <output>
%     density, optimaldensity,
%     pathsamples.txt, pathprobabilities.txt
%  </ouput>
% </header>

function poistatsodf(instem, outdir, seedstem, seednums, samplestem, ...
                  ncontrolpoints, initsigma, nsamplepoints, maskstem);

version = '$Id: poistatsodf.m,v 1.0 2007/3/12 19:57:49 markk Exp $';
geo = load(['/homes/1/markk/research/mwf/directions/752-dodeca5-vert.txt']);

fprintf('poistatsodf\n');

% load volume dimensions
try
  [rows cols frames slice0 slices endian bext] = ...
      fmri_bfiledim(instem);
catch
  fprintf('ERROR: loading %s\n', instem);
  exit;
end

% load data
fprintf('Loading odf volume ... ');
tic;
try
  odftmp = fmri_ldbvolume(instem);
catch
  fprintf('ERROR: loading %s\n', instem);
  exit;
end
fprintf('done (%g)\n',toc);

% load data
fprintf('Loading sample volume ... ');

tic;
try
  sampvol = fmri_ldbvolume(samplestem);
catch
  fprintf('ERROR: loading %s\n', samplestem);
  exit;
end
fprintf('done (%g)\n',toc);

% load seed points
seeds = fmri_ldbvolume(seedstem);
if isempty(seednums)
  seedvalues = sort(unique(seeds(seeds~=0)));
else
  seedvalues = str2num(seednums);
end

nseeds = length(seedvalues);

for idx = 1:nseeds
  [i j k] = ind2sub(size(seeds),find(seeds==seedvalues(idx)));
  X = [i j k];
  com = mean(X,1);
  [null jdx] = min(distmat(com, X)); jdx = jdx(1);
  initpoints(idx,:) = X(jdx,:);  
end

[i j k] = ind2sub(size(seeds),find(seeds==seedvalues(1)));
seedstart = [i j k];
[i j k] = ind2sub(size(seeds),find(seeds==seedvalues(end)));
seedend = [i j k];


% load mask if maskstem specified
if ~isempty(maskstem)
  tic;
  fprintf('Loading mask volume ... ');
  mask = fmri_ldbvolume(maskstem);
  mask = mask~=0;
  fprintf('done (%g)\n',toc);
else
  mask = ones(slices,rows,cols);
end


% generate mask lookup volume
mask = mask .* all(odftmp, 4);
maskidx = find(reshape((mask),[slices*rows*cols 1]));
look = zeros(size(mask));
look(maskidx) = 1:length(maskidx);
flatodf = reshape(odftmp,[slices*rows*cols ,size(geo,1)]);
clear odftmp;
odflist = zeros(length(maskidx),size(geo,1));
odflist = flatodf(maskidx,:);
clear flatodf;

if ~initsigma
  
  % do not perform optimization
  fprintf('Skipping path optimization ... \n');
  basepath = origpath;
  
else 
  
  fprintf('Starting optimization ...\n');

  randn('state',0);   

  % parameters  

  % -- paths
  nreplica = 100;
  steps = 50;

  % -- temperature & cooling
  temp = .1*linspace(.5,1,nreplica);
  coolfactor = 0.995; 
  timeconst = 2*1e2;
  replicaexchprob = .05;

  % -- convergence
  lulldenergy = .5*1e-3;
  maxlull = 10; 
  maxtime = 300;  
  
  % initialize energy
  minenergy = realmax*ones(nreplica,1); 
  globalminenergy = realmax;
  energyprev = realmax*ones(nreplica,1);  

  % intitialization
  lull = 0;
  time = 1; 
  
  % initialize paths
  fprintf('Initializing paths ...\n');  
  origpath = rethreadpath(initpoints, ncontrolpoints+2);
  lowtrialpath = origpath;
  for i = 1:nreplica
    basepath{i} = origpath;
    prevpath{i} = rethreadpath(origpath, steps);
    trialpath{i} = zeros(steps,3);
    bestpath{i} = zeros(steps,3);
  end  
  
  fprintf('Starting calculation ...\n');

  while lull < maxlull & time < maxtime
    sigma = initsigma*exp(-time/timeconst);
    
    exchanges = 0; tic;
    for i = 1:nreplica
      
      % generate perturbed path
      if time > 1, prevpath{i} = trialpath{i}; end;
      

      perturb = sigma*diag(rand(ncontrolpoints,1))*sphererand(ncontrolpoints);
      
      lowtrialpath(2:end-1,:) = basepath{i}(2:end-1,:) + perturb;
      lowtrialpath(1,:) = ...
          constrainedrnd(basepath{i}(1,:), seedstart, sigma);
      lowtrialpath(end,:) = ...
          constrainedrnd(basepath{i}(end,:), seedend, sigma);
      
      trialpath{i} = rethreadpath(lowtrialpath, steps);
      rpath = round(trialpath{i});      
      
      odfs = (1e-200)*ones(steps, length(geo));
      
      idx = inboundsidx(rpath, size(mask));
      odfidx = look(idx);
      goodindices = odfidx~=0;     
      odfs(goodindices,:) = abs(odflist(odfidx(goodindices),:));
      
      % calculate path energy      
      energy(i) = odfpathenergy(trialpath{i}, odfs, geo);             
            
      % check for Metropolis-Hastings update
      Delta = (energy(i)-energyprev(i))/temp(i);
      updateprobability = min(1, exp(-Delta));
      if rand(1) <= updateprobability;        
        basepath{i} = lowtrialpath; 
        bestpath{i} = trialpath{i};
        
        if energy(i) < globalminenergy
          globalbestpath = trialpath{i};          
          globalminenergy = energy(i);
        end
        
      else
        energy(i) = energyprev(i);
      end
      
      
      % replica exchange
      if  time > 1 & rand(1) < replicaexchprob
        replicaenergies = energy;
        [null ranks] = sort(replicaenergies);
        
        idx = ceil((nreplica-1)*rand(1)); jdx = idx+1;      
        idx = ranks(idx); jdx = ranks(jdx);
        
        Dbeta = 1/temp(idx) - 1/temp(jdx);
        
        Denergy = replicaenergies(idx) - replicaenergies(jdx);
        Delta = -Dbeta * Denergy;
        exchprob = min(1,exp(-Delta));
        
        if rand(1) <= exchprob % exchage replica
          
          exchanges = exchanges + 1;
          % exchange temperatures
          tmptemp = temp(idx);
          temp(idx) = temp(jdx);
          temp(jdx) = tmptemp;
          
        end            
        
      end % replica exchange   
      
    end % nreplica
    
    tm = toc;

    denergy = (mean(energy)-mean(energyprev))/mean(energy);

    if abs(denergy) < lulldenergy
      lull = lull + 1;
    else
      lull = 0;
    end
        
    energyprev = energy;
    temp = coolfactor*temp;    
    
    if 1 == 1      
      fprintf('%3d   lull: %2d  denergy: %+5f  mean: %f  bottom: %f   min: %f   globalmin: %f  exchs: %2d  (%f)\n', ...
              time, lull, denergy, mean(energy), prctile(energy,10), min(energy), globalminenergy, exchanges, tm);
    end
    
    time = time + 1;
    
  end  
end
  

  

fprintf('\n');
fprintf('Calculation complete ... \n');
fprintf('Constructing equilibrium density volume ... \n');
tic;
ps = exp(-energy); ps = ps/sum(ps);
density = zeros(size(mask));

for i = 1:nreplica
  if ~mod(i,5), fprintf('%d ',i);end;
  if ps(i) > (1e-1/nreplica) % if replica contributes
    density = density + ps(i)*pnts2vol(bestpath{i}, size(density),.5);
  end
end
density = density / sum(density(:));

optimaldensity = pnts2vol(globalbestpath, size(mask), .5);


% calculate path samples
gpath = rethreadpath(globalbestpath, nsamplepoints);
samples = interpn(sampvol, gpath(:,1), gpath(:,2), gpath(:,3), ...
                  '*cubic');

% calculate path probabilities
odfs = (1e-200)*ones(steps, length(geo));
rpath = round(globalbestpath);      
idx = inboundsidx(rpath, size(mask));
odfidx = look(idx);
goodindices = odfidx~=0;     
odfs(goodindices,:) = abs(odflist(odfidx(goodindices),:));
[energy energies] = odfpathenergy(globalbestpath, odfs, geo);             
pathprobabilities = exp(-energies);
pathprobabilities = csapi(1:length(pathprobabilities), pathprobabilities, ...
                          linspace(1,length(pathprobabilities),nsamplepoints));


% write output
fprintf('\n');
fid = fopen([outdir '/pathsamples.txt'], 'w');
fprintf(fid, '%f\n', samples);
fclose(fid);

fid = fopen([outdir '/pathprobabilities.txt'], 'w');
fprintf(fid, '%f\n', pathprobabilities);
fclose(fid);

%fid = fopen([outdir '/resampledpath.txt'], 'w');
%fprintf(fid, '%f %f %f\n', src2vol(globalbestpath)');
%fclose(fid);

fprintf('Saving path density ... \n');
fmri_svbvolume(density, [outdir '/density']);

fprintf('Saving optimal path density ... \n');
fmri_svbvolume(optimaldensity, [outdir '/optimaldensity']);


exit;
