clc; clear; close all;
% 加载图形数据
fig = openfig('1k.fig');
ax = gca; % 获取当前坐标轴
h = findobj(ax, 'Type', 'line'); % 获取所有的线条对象
x_data = h.XData; % 获取线条的X数据
y_data = h.YData; % 获取线条的Y数据
% 截取0-0.073秒之间的信号========
indices = find(x_data >= 0.90 & x_data <= 0.973);
x_truncated = x_data(indices);
y_truncated = y_data(indices);
% 创建从0开始的时间轴用于绘图
x_plot = x_truncated - min(x_truncated); % 平移时间轴使其从0开始
% 计算采样频率
Fs = 1/mean(diff(x_truncated));

% 三分之一倍频程滤波 (中心频率1kHz)
fc = 1000; % 中心频率 1kHz
f_low = fc / (2^(1/6));   % 下限频率：约 891 Hz
f_high = fc * (2^(1/6));  % 上限频率：约 1122 Hz

% 使用简单的巴特沃斯带通滤波器
Wn1 = f_low / (Fs/2);
Wn2 = f_high / (Fs/2);
[b, a] = butter(2, [Wn1 Wn2], 'bandpass');

% 应用滤波器
y_truncated = filter(b, a, y_truncated);

disp(['三分之一倍频程滤波完成，通带范围: ' num2str(f_low,'%.1f') ' - ' num2str(f_high,'%.1f') ' Hz']);
% 计算频域分析所需参数
N = length(y_truncated);
Y = fft(y_truncated);
Y_abs = abs(Y/N); % 归一化幅度
Y_abs = Y_abs(1:floor(N/2)+1); % 只取一半频谱（单边谱）
Y_abs(2:end-1) = 2*Y_abs(2:end-1); % 乘以2（除了DC和Nyquist频率）
% 频率轴
f = Fs*(0:floor(N/2))/N;
% 绘制原始信号的频域图
figure('Name', '原始信号分析', 'NumberTitle', 'off');
% 绘制时域图
subplot(2,1,1);
plot(x_plot, y_truncated); % 使用新的时间轴绘图
title('原始截取信号（时域）', 'FontName', '宋体');
xlabel('时间 (s)', 'FontName', '宋体');
ylabel('幅度', 'FontName', '宋体');
grid on;
% 绘制频谱图
RS = -170;
subplot(2,1,2);
plot(f/1000, Y_abs);
title('原始截取信号频谱', 'FontName', '宋体');
xlabel('频率 (kHz)', 'FontName', '宋体');
ylabel('幅度', 'FontName', '宋体');
grid on;
xlim([0 2]); % 调整显示范围为0-2kHz，适合1kHz中心频率
%% 截取指定时间范围的信号***********
% 使用指定的固定时间范围截取信号
t1 = 0.918559; % 起始时间（秒）
t2 = 0.920809; % 结束时间（秒）
% 截取设置的信号区域
scatter_indices = find(x_truncated >= t1 & x_truncated <= t2);
x_scatter = x_truncated(scatter_indices);
y_scatter = y_truncated(scatter_indices);
% 为散射信号创建从0开始的时间轴（如果需要用于绘图）
x_scatter_plot = x_scatter - min(x_truncated); % 使用相同的参考点保持一致性
% 计算散射信号的频谱
N_scatter = length(y_scatter);
Y_scatter = fft(y_scatter);
Y_scatter_abs = abs(Y_scatter/N_scatter);
Y_scatter_abs = Y_scatter_abs(1:floor(N_scatter/2)+1);
Y_scatter_abs(2:end-1) = 2*Y_scatter_abs(2:end-1);
% 散射信号的频率轴
f_scatter = Fs*(0:(floor(N_scatter/2)))/N_scatter;
% 计算散射声强
% 计算每个时间点的瞬时声强
v_squared = y_scatter.^2 + eps; % 加eps防止log(0)计算错误
I_instant = 10*log10(v_squared) - RS;
% 计算平均声强
v_squared_mean = mean(v_squared);
I_mean = 10*log10(v_squared_mean) - RS;
% 显示结果
disp('==== 接收信号强度结果 ====');
disp([' I_mean = ' num2str(I_mean) ' dB']);