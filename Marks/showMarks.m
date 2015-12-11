function Mark_expand=showMarks(origin,mark) 
figure; imshow(origin); hold on ; 
scatter(mark(:,1),mark(:,2),20,[1,0,1],'filled'); hold on; 
%k = convhull(mark(:,1),mark(:,2));
k=[ 68  67  66  65  64  63  62    61    52    54    55    56    57  58  59   60 ];
Mark_expand= zeros(size(k,2),2);
for i= 0:size(k,2)-2
    for j =0:9
    Mark_expand(i*10+j+1,1)= mark(k(i+1),1)* (10-j)/10+mark(k(i+2),1)*j/10;
    Mark_expand(i*10+j+1,2)= mark(k(i+1),2)* (10-j)/10+mark(k(i+2),2)*j/10;
    end
end 

scatter(Mark_expand(:,1),Mark_expand(:,2),20,[1,0,1],'filled'); hold on; 

%plot(mark(k,1),mark(k,2));

end 