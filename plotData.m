clf

timeD = 1:true_end;
dayTime = timeD / 24;

plot(dayTime, Cm(1:true_end), 'LineWidth', 2);
hold on
plot(dayTime, V(1:true_end), 'LineWidth', 2);

ylabel("N")
xlabel("Day")
legend("Cases", "Vacc. Immunity")
grid on

x0=10;
y0=10;
width=1000;
height=500;
set(gcf,'position',[x0,y0,width,height])

figure(2)
plot(dayTime, D(1:true_end), 'LineWidth', 2);
legend("Deaths")
ylabel("N")
xlabel("Day")
grid on

x0=10;
y0=10;
width=1000;
height=500;
set(gcf,'position',[x0,y0,width,height])

%%
vaccineMonths = vaccineIntervals / (24*30);
plot(vaccineMonths,Cm_mean, 'LineWidth', 2)
legend("Cases")
ylabel("N")
xlabel("Vaccine Interval (Months)")
title("Five year simulation with sigma = 1/(24*30*5)")

grid on

x0=10;
y0=10;
width=1000;
height=500;
set(gcf,'position',[x0,y0,width,height])

%%
vaccineMonths = vaccineIntervals / (24*30);
plot(vaccineMonths,D_mean, 'LineWidth', 2)
legend("Deaths")
ylabel("N")
xlabel("Vaccine Interval (Months)")
title("Five year simulation with sigma = 1/(24*30*6)")

grid on

x0=10;
y0=10;
width=1000;
height=500;
set(gcf,'position',[x0,y0,width,height])
%%
vaccineMonths = vaccineIntervals / (24*30);
plot(vaccineMonths,nVD_mean, 'LineWidth', 2)
legend("Doses")
ylabel("N")
xlabel("Vaccine Interval (Months)")
title("Five year simulation with sigma = 1/(24*30*6)")

grid on

x0=10;
y0=10;
width=1000;
height=500;
set(gcf,'position',[x0,y0,width,height])