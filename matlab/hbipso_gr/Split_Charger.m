function post_split_chargers_only()
% Hậu xử lý HBIPSO-GR: chỉ xuất số CHARGER theo loại + Chargers_total
% Input:  evcs_data.mat  (EVcount, SCF, maxCharger, STATIONS, TYPES, ...)
%         hbipso_best.mat (CSP, s, x)
% Output: chargers_per_station.csv (Station, Open, Chargers_11/60/150kW, Chargers_total)

clc;

%% ====== Policy / Parameters ======
% Số cổng/charger
ports11  = 4;   % 11 kW: 4 ports
ports60  = 2;   % 60 kW: 2 ports
ports150 = 2;   % 150 kW: 2 ports

% Chính sách bus (150 kW) chỉ ở CC-BDX
bdx_min_bus_chargers = 2;                 % tối thiểu charger bus tại BDX
rebalance_to = {'CC-TT1','CC-TM2','CC-TLC'};
min_total_stalls_each = 50;               % dùng nội bộ để phân bổ, không xuất

%% ====== Load data ======
S = load('evcs_data.mat');      % D, EVcount, SCF, maxCharger, STATIONS, TYPES, ...
R = load('hbipso_best.mat');    % CSP, s, x

types    = string(S.TYPES(:));
stations = string(S.STATIONS(:));
nT = numel(types); m = numel(stations);

% Nhóm loại
grp11  = types=="xe_may";
grp60  = ismember(types,["oto5","oto7","taxi5","taxi7"]);
grp150 = types=="bus";

% Nhu cầu theo điểm x loại
D_it = S.EVcount .* S.SCF;           % [n x T]
% Tải tại trạm theo loại (từ ma trận gán x của HBIPSO)
L_jt  = R.x' * D_it;                  % [m x T]
L11   = sum(L_jt(:,grp11),2);
L60   = sum(L_jt(:,grp60),2);
L150  = sum(L_jt(:,grp150),2);
Lsum  = L11 + L60 + L150;
Lsum(Lsum==0) = 1;

s_tot = R.s(:);                       % tổng TRỤ (stalls) mỗi trạm (không xuất)
CSP   = R.CSP(:)>0;

% Giới hạn theo loại (số CHARGER tối đa)
max11  = S.maxCharger(:,grp11);            % [m x 1]
max60  = sum(S.maxCharger(:,grp60),2);     % [m x 1] gộp 4 loại
max150 = S.maxCharger(:,grp150);           % [m x 1]

%% ====== Phân bổ TRỤ nội bộ theo tỷ trọng tải (không xuất) ======
s11_raw  = s_tot .* (L11 ./ Lsum);
s60_raw  = s_tot .* (L60 ./ Lsum);
s150_raw = s_tot .* (L150 ./ Lsum);

% Largest remainder để tổng = s_tot
s11 = floor(s11_raw);  s60 = floor(s60_raw);  s150 = floor(s150_raw);
rem = s_tot - (s11+s60+s150);
if any(rem>0)
    frac = [s11_raw - s11, s60_raw - s60, s150_raw - s150];  % [m x 3]
    for j=1:m
        while rem(j)>0
            [~,ord] = sort(frac(j,:),'descend');
            for k=1:3
                idx = ord(k);
                if idx==1, s11(j)=s11(j)+1;
                elseif idx==2, s60(j)=s60(j)+1;
                else, s150(j)=s150(j)+1;
                end
                rem(j)=rem(j)-1;
                if rem(j)==0, break; end
            end
        end
    end
end

%% ====== Ràng buộc bus chỉ ở CC-BDX (trên không gian TRỤ) ======
jBDX = find(stations=="CC-BDX",1);
if isempty(jBDX), error('Không tìm thấy "CC-BDX" trong STATIONS.'); end

cut150 = sum(s150) - s150(jBDX);   % tổng 150kW ngoài BDX
s150(:) = 0;
s150(jBDX) = cut150;

% Ép tối thiểu charger bus tại BDX (đổi charger -> TRỤ)
s150_min = ports150 * bdx_min_bus_chargers;
s150(jBDX) = max(s150(jBDX), s150_min);

% Giữ tổng stalls mỗi trạm = s_tot, ưu tiên 60 -> 11
for j=1:m
    surplus = s11(j)+s60(j)+s150(j) - s_tot(j);
    if surplus>0
        while surplus>0
            [mx, idx] = max([s60(j) s11(j) s150(j)]);
            if mx<=0, break; end
            if idx==1, s60(j)=s60(j)-1;
            elseif idx==2, s11(j)=s11(j)-1;
            else, s150(j)=max(0,s150(j)-1);
            end
            surplus = surplus-1;
        end
    elseif surplus<0
        while surplus<0
            room = [inf, inf, inf]; % tạm thời cho phép, sẽ cắt bằng maxCharger sau
            [~, idx] = max(room);
            if idx==1, s60(j)=s60(j)+1; else, s11(j)=s11(j)+1; end
            surplus = surplus+1;
        end
    end
end

%% ====== Cắt theo maxCharger sau khi quy đổi sang CHARGER ======
% Quy đổi TRỤ -> CHARGER
c11  = ceil(s11  / ports11);
c60  = ceil(s60  / ports60);
c150 = ceil(s150 / ports150);

% Áp trần theo maxCharger
c11  = min(c11,  max11);
c60  = min(c60,  max60);
c150 = min(c150, max150);

% Nếu bị cắt làm giảm tổng port, cố gắng bù về tổng port mục tiêu bằng 60 -> 11
for j=1:m
    target_ports = s_tot(j);                  % số port mục tiêu (từ stalls)
    curr_ports   = c11(j)*ports11 + c60(j)*ports60 + c150(j)*ports150;
    while curr_ports < target_ports
        % Ưu tiên tăng 60kW rồi 11kW nếu còn room
        if c60(j) < max60(j)
            c60(j) = c60(j)+1;
        elseif c11(j) < max11(j)
            c11(j) = c11(j)+1;
        else
            break; % hết room
        end
        curr_ports = c11(j)*ports11 + c60(j)*ports60 + c150(j)*ports150;
    end
end

%% ====== Tránh dồn: đảm bảo tối thiểu stalls nội bộ cho một số trạm (không xuất) ======
rebIdx = arrayfun(@(nm) find(stations==nm,1), string(rebalance_to));
rebIdx = rebIdx(~isnan(rebIdx));
for j = rebIdx(:).'
    curr_ports = c11(j)*ports11 + c60(j)*ports60 + c150(j)*ports150;
    need_ports = max(0, min_total_stalls_each - curr_ports);
    if need_ports>0
        donors = setdiff(1:m, [j jBDX]);
        [~,donorOrd] = sort(c11(donors)*ports11 + c60(donors)*ports60 + c150(donors)*ports150, 'descend');
        for d = donors(donorOrd).'
            while need_ports>0
                moved = false;
                if c60(d)>0 && c60(j) < max60(j)
                    c60(d)=c60(d)-1; c60(j)=c60(j)+1; moved=true; need_ports = need_ports - ports60;
                elseif c11(d)>0 && c11(j) < max11(j)
                    c11(d)=c11(d)-1; c11(j)=c11(j)+1; moved=true; need_ports = need_ports - ports11;
                end
                if ~moved, break; end
            end
            if need_ports<=0, break; end
        end
    end
end

%% ====== Xuất chỉ CHARGER + tổng ======
Chargers_total = c11 + c60 + c150;

T = table( ...
    stations, CSP, c11, c60, c150, Chargers_total, ...
    'VariableNames', {'Station','Open','Chargers_11kW','Chargers_60kW','Chargers_150kW','Chargers_total'});

disp(T);
writetable(T, 'chargers_per_station.csv');
fprintf('\nSaved: chargers_per_station.csv\n');

% Thống kê nhanh
fprintf('\nTỔNG CHARGER | 11kW=%d, 60kW=%d, 150kW=%d, ALL=%d\n', ...
    sum(c11), sum(c60), sum(c150), sum(Chargers_total));
end
