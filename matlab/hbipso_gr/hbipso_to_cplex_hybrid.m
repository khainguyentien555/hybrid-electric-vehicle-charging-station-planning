% hbipso_to_cplex_hybrid_compact.m  (tạo evcs_hybrid.dat từ evcs_data.mat + hbipso_best.mat)
clear; clc;

D = load('evcs_data.mat');  H = load('hbipso_best.mat');

% --- lấy field (có fallback tên biến) ---
POINTS   = pick(D, {'POINTS','points'});
STATIONS = pick(D, {'STATIONS','stations'});
TYPES    = pick(D, {'TYPES','types'});
EVcount    = todbl(pick(D, {'EVcount'}));
maxCharger = todbl(pick(D, {'maxCharger'}));
DIST_m     = todbl(pick(D, {'DIST','dist','Dist'}));
SCF        = vec(pick(D, {'SCF','scf'}));
areaT      = vec(pick(D, {'areaT','area'}));
powerT     = vec(pick(D, {'powerT','power'}));

alpha = pick(D, {'alpha'}, 0.00036);
beta  = pick(D, {'beta'},  0.00215);
w1    = pick(D, {'w1'},    1/3);
w2    = pick(D, {'w2'},    0.33);
w3    = pick(D, {'w3'},    0.33);

% --- indices tiện dùng trong OPL ---
idxBus = find(strcmpi(TYPES,'bus'),1);   assert(~isempty(idxBus),'No TYPE "bus"');
idxBDX = find(strcmpi(STATIONS,'CC-BDX'),1); assert(~isempty(idxBDX),'No STATION "CC-BDX"');

% --- DIST: nếu còn là mét thì đổi sang km ---
DIST = DIST_m; if mean(DIST_m(:),'omitnan') > 20, DIST = DIST_m/1000; end

% --- bound tổng trụ từ HBIPSO ---
J = numel(STATIONS);
sHB = pick(H, {'s'}, 2*ones(1,J));  sHB = vec(sHB);
s_lb = max(1, round(sHB-2));
s_ub = max(s_lb, round(sHB+2));

% --- ghi file .dat ---
fn='evcs_hybrid.dat'; fid=fopen(fn,'w'); assert(fid~=-1,'Cannot open %s',fn);

fprintf(fid,'POINTS={%s};\n',   qlist(POINTS));
fprintf(fid,'STATIONS={%s};\n', qlist(STATIONS));
fprintf(fid,'TYPES={%s};\n',    qlist(TYPES));

fprintf(fid,'alpha=%.12g;\n beta=%.12g;\n w1=%.12g;\n w2=%.12g;\n w3=%.12g;\n',alpha,beta,w1,w2,w3);
fprintf(fid,'idxBDX=%d;\n idxBus=%d;\n',idxBDX,idxBus);

writeVec(fid,'SCF',SCF);   writeVec(fid,'areaT',areaT);  writeVec(fid,'powerT',powerT);
writeVec(fid,'s_lb',s_lb); writeVec(fid,'s_ub',s_ub);

writeMat(fid,'EVcount',EVcount);
writeMat(fid,'maxCharger',maxCharger);
writeMat(fid,'DIST',DIST);

fclose(fid);
fprintf('✔ Created %s\n',fn);

% ================= local helpers =================
function x = pick(S, names, default)
    x = [];
    for k=1:numel(names)
        if isfield(S,names{k}), x = S.(names{k}); return; end
    end
    if nargin<3, error('Missing field: %s', strjoin(names,'/')); end
    x = default;
end

function M = todbl(M)
    if iscell(M), M = cell2mat(M); end
end

function v = vec(v)
    if iscell(v), v = cell2mat(v); end
    if isstruct(v), v = struct2array(v); end
    v = v(:)'; % row
end

function s = qlist(C)
    if ~iscellstr(C), C = cellstr(C); end
    s = char(strjoin(compose('"%s"',C),','));
end

function writeVec(fid,name,v)
    v = v(:)'; fprintf(fid,'%s=[%s];\n',name, char(strjoin(compose('%.12g',v),', ')));
end

function writeMat(fid,name,M)
    fprintf(fid,'%s=[\n',name);
    for i=1:size(M,1)
        row = char(strjoin(compose('%.12g',M(i,:)),', '));
        if i<size(M,1), fprintf(fid,'  %s;\n',row); else, fprintf(fid,'  %s\n',row); end
    end
    fprintf(fid,'];\n');
end
