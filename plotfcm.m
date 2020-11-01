function plotfcm(data,center,U,obj_fcn)
%plotting function
figure(1)
subplot(5,1,1);
plot(U(1,:),'-b');
title('Membership Matrix U')
ylabel('Cluster 1')
subplot(5,1,2);
plot(U(2,:),'-r');
ylabel('Cluster 2')
xlabel('n_cluster')
subplot(5,1,3);
plot(U(2,:),'-y');
ylabel('Cluster 3')
xlabel('n_cluster')
subplot(5,1,4);
plot(U(2,:),'-g');
ylabel('Cluster 4')
xlabel('n_cluster')
subplot(5,1,5);
plot(U(2,:),'-p');
ylabel('Cluster 5')
xlabel('n_cluster')

figure(2)
grid on
plot(obj_fcn);
title('Xie-Beni Index');
xlabel('n_iter')
ylabel('Obj_fcn')

figure(3)
title('Clusters');
plot(data(:,1),data(:,2),'*r');
maxU = max(U);
index1 = find(U(1,:)==maxU);
index2 = find(U(2,:)==maxU);
index3 = find(U(3,:)==maxU);
index4 = find(U(4,:)==maxU);
index5 = find(U(5,:)==maxU);
plot(data(index1,1),data(index1,2),'*b');
hold on
plot(data(index2,1),data(index2,2),'*r');
plot(data(index3,1),data(index3,2),'*y');
plot(data(index4,1),data(index4,2),'*g');
plot(data(index5,1),data(index5,2),'*c');
plot(center(1,1),center(1,2),'ob','Markersize',5,'linewidth',3)
plot(center(2,1),center(2,2),'or','Markersize',5,'linewidth',3)
plot(center(3,1),center(3,2),'oy','Markersize',5,'linewidth',3)
plot(center(4,1),center(4,2),'og','Markersize',5,'linewidth',3)
plot(center(5,1),center(5,2),'oc','Markersize',5,'linewidth',3)
hold off;
end