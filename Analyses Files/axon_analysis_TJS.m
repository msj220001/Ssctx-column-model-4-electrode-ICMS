clear all % Clear all variables from the workspace
close all % Close all open figure windows

% Load spatial data of neurons and their connections
load('realx.dat') % X-coordinates of neuron location
load('realy.dat') % Y-coordinates of neuron locations
load('realz.dat') % Z-coordinates of neuron locations

% Angular orientations of neurons
load('realang.dat')

% Number of cells per ID (assumed from 1 to 25)
load('cell_cnt.dat')

% Counter for storing final axon positions
cnt_cnt=1;

% Counter for figure numbers
figNum = 0;

% Produce progression plots for designated timestamps
for timestamps = 205:1:206
    figNum = figNum+1;

    % Loop through 25 different neuron sets (files)
    for id=1:25
    
        % Stimulation amplitude (not used in computations)
        amp=[16.5];
        
        % Get the number of cells in the current dataset
        cell_id=1:cell_cnt(id);
        
        % Load interneuron spatial data (axon and branch points)
        intx=load(['intx_' num2str(id) '.dat']);
        inty=load(['inty_' num2str(id) '.dat']);
        intz=load(['intz_' num2str(id) '.dat']);
        
        % Load axon locations
        x_axon=load(['x_axon_' num2str(id) '.dat']);
        y_axon=load(['y_axon_' num2str(id) '.dat']);
        z_axon=load(['z_axon_' num2str(id) '.dat']);
        
        % Load soma activation timing data
        % soma_coord=load(['soma_coord_' num2str(id) '.dat']);
        
        % Load axon activation timing data
        load(['data_axon' num2str(id) '.mat']);
        
        % Define electrode coordinates
        % Electrode 1
        elec_x=200;
        elec_y=1550;
        elec_z=200;
        % Electrode 2
        elec_x2=200;
        elec_y2=1450;
        elec_z2=200;
        % Electrode 3
        elec_x3=200;
        elec_y3=1350;
        elec_z3=200;
        % Electrode 4
        elec_x4=200;
        elec_y4=1250;
        elec_z4=200;
    
        % Stores IDs of eliminated neurons
        eli_a=[];
        % Final list of eliminated neurons
        eliminate=[];
        
        cnt=1;
        % Iterate through each neuron
        for k=1:cell_cnt(id)
            
            % Compute the adjusted neuron positions based on real-world coordinates and angles
            net_ad_x1a=(((realx(sum(cell_cnt(1:id))-cell_cnt(id)+k ))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k )))-((realz(sum(cell_cnt(1:id))-cell_cnt(id)+k ))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k ))))-(realx(sum(cell_cnt(1:id))-cell_cnt(id)+k ));
            net_ad_y1a=(realy(sum(cell_cnt(1:id))-cell_cnt(id)+k ))-(realy(sum(cell_cnt(1:id))-cell_cnt(id)+k ));
            net_ad_z1a=(((realx(sum(cell_cnt(1:id))-cell_cnt(id)+k ))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k )))+((realz(sum(cell_cnt(1:id))-cell_cnt(id)+k ))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k ))))-(realz(sum(cell_cnt(1:id))-cell_cnt(id)+k ));
            
            % Loop through interneuron points
            for i=1:length(intx)
                %for j=1:nseg(i)
                    
                    % Transform the interneuron coordinates based on the neuron angle
                    x1a=(((realx(sum(cell_cnt(1:id))-cell_cnt(id)+k )+intx(i))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k )))-((realz(sum(cell_cnt(1:id))-cell_cnt(id)+k )+intz(i))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k ))));
                    y1a=(realy(sum(cell_cnt(1:id))-cell_cnt(id)+k )+inty(i));
                    z1a=(((realx(sum(cell_cnt(1:id))-cell_cnt(id)+k )+intx(i))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k )))+((realz(sum(cell_cnt(1:id))-cell_cnt(id)+k )+intz(i))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+k ))));
                
                    % Adjust final positions relative to transformed neuron positions
                    x_final_a=x1a-net_ad_x1a;
                    y_final_a=y1a-net_ad_y1a;
                    z_final_a=z1a-net_ad_z1a;
                
                    % Compute distance between axon component and electrode
                    rdist_a=(sqrt(((elec_x-x_final_a)^2)+(((elec_y-y_final_a)^2)+((elec_z-z_final_a)^2))));
                    rdist_b=(sqrt(((elec_x2-x_final_a)^2)+(((elec_y2-y_final_a)^2)+((elec_z2-z_final_a)^2))));
                    rdist_c=(sqrt(((elec_x3-x_final_a)^2)+(((elec_y3-y_final_a)^2)+((elec_z3-z_final_a)^2))));
                    rdist_d=(sqrt(((elec_x4-x_final_a)^2)+(((elec_y4-y_final_a)^2)+((elec_z4-z_final_a)^2))));
                    
                    % If the axon component is within 15 um of the electrode, mark it for elimination
                    if rdist_a<15 || rdist_b<15 || rdist_c<15 || rdist_d<15
                        eli_a(cnt)=k;
                        cnt=cnt+1;
                    end
                %end
            end
        end
        
        % If any neurons were marked for elimination, store them
        if ~isempty(eli_a)
            eliminate=unique(eli_a);
            % Eliminate all neurons & processes within 15 um of the electrode, check
            % paper for more specifics as to why
        end
        
        % Delete all data after 209 ms (currently set at 202 ms)
        for i = 1:cell_cnt(id)
            %disp(num2str(i));
            if ~isempty(data_axon(i).times)
                for j = 1:length(data_axon(i).times)
                    %for k=1:length(data_axon(i).times{1,j})
                    for k = length(data_axon(i).times{1, j}):-1:1
                        disp(['Fig. #', num2str(figNum) ', cell_typeid = ', num2str(id), ', cell_cnt = ' num2str(cell_cnt(id)), ', data_axon(i = ', num2str(i), ').times{1, j = ', num2str(j), '}(k = ', num2str(k), ') = ', num2str(data_axon(i).times{1, j}(k))]);
                        %if data_axon(i).times{1, j}(k) < 201.2 || data_axon(i).times{1, j}(k) > 201.5
                        %if data_axon(i).times{1, j}(k) >= 209
                        if data_axon(i).times{1, j}(k) > timestamps
                            data_axon(i).times{1, j}(k) = [];
                        end
                    end
                end
            end
        end
        
        % Store valid neurons for further analysis
        real_cell_id=[];
        
        cnt=1;
        %Keep all data after 201 ms (201 is because the delay before stimulation is 201 ms)
        for i = 1:cell_cnt(id)
            if ~isempty(data_axon(i).times{1,1})
                for j=1:length(data_axon(i).times)
                    dta(cnt).times{1,j}=sort(data_axon(i).times{1,j})-201;
                end
                real_cell_id(cnt)=cell_id(i); 
                cnt=cnt+1;
            end
        end
        
        % Remove neurons that were within 15 um of the electrode
        if ~isempty(real_cell_id)
        
            % Compute final axon locations for plotting
            for i=1:length(dta)
                for j=1:length(dta(1).times)
                    if ~isempty(dta(i).times{1,j})
                    dta_temp(j)=dta(i).times{1,j}(1);
                    else
                        dta_temp(j)=NaN;
                    end
                end
                dta_final(i,1)=min(dta_temp);
                dta_final(i,2)=find(dta_temp==min(dta_temp),1,'first');
                clear dta_temp
            end
        
            ind_find=[];
            
            cmbt=1;
            if ~isempty(eliminate)
                for i=1:length(eliminate)
                    if ~isempty(find(real_cell_id==eliminate(i), 1)) 
                        ind_find(cmbt)=find(real_cell_id==eliminate(i));
                        cmbt=cmbt+1;
                    end
                end
                real_cell_id(ind_find)=[];
                dta_final(ind_find,:)=[];
            end
        
            for i=1:length(real_cell_id)
                
                net_ad_x1=(((realx(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i))))-((realz(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))))-(realx(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)));
                net_ad_y1=(realy(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))-(realy(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)));
                net_ad_z1=(((realx(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i))))+((realz(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))))-(realz(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)));
                
                x1=((x_axon(dta_final(i,2))+realx(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i))))-((z_axon(dta_final(i,2))+realz(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i))));
                y1=y_axon(dta_final(i,2))+realy(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i));
                z1=((x_axon(dta_final(i,2))+realx(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*sin(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i))))+((z_axon(dta_final(i,2))+realz(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i)))*cos(realang(sum(cell_cnt(1:id))-cell_cnt(id)+real_cell_id(i))));
            
                x_final=x1-net_ad_x1;
                y_final=y1-net_ad_y1;
                z_final=z1-net_ad_z1;
                
                % Store processed coordinates for visualization
                % real_cell_id_final_1(cnt_cnt)=real_cell_id(i);
                x_coord(cnt_cnt)=x_final;
                y_coord(cnt_cnt)=y_final;
                z_coord(cnt_cnt)=z_final;
                cnt_cnt=cnt_cnt+1;
            
                clear net_ad_x1 net_ad_y1 net_ad_z1 x1 y1 z1 x_final y_final z_final 
            end
        end
        
        clear eliminate eli eli_a x_axon y_axon z_axon intx inty intz data_axon dta dta_final real_cell_id cell_id  
    
    end
    
    % load('real_cell_id_final.mat');
    % 
    % for bd=1:length(real_cell_id_final)
    %     ijk(bd)=find(real_cell_id_final_1==real_cell_id_final(bd));
    % end
    
    tru_id=1:1:length(realx);
    
    % dist=sqrt(((x_coord-elec_x).^2)+((y_coord-elec_y).^2)+((z_coord-elec_z).^2));
    
    % Plot activated axons in red
    figure(figNum)
    plot3(x_coord,z_coord,y_coord,'.r','Markersize',6)
    hold on
    
    % Overlay all neuron components with different colors
    for i=1:length(tru_id)
        if tru_id(i)>=1 && tru_id(i)<=450
            plot3(realx(tru_id(i)),realz(tru_id(i)),realy(tru_id(i)),'.m','Markersize',1)
            hold on
        elseif tru_id(i)>=451 && tru_id(i)<=2690 
            plot3(realx(tru_id(i)),realz(tru_id(i)),realy(tru_id(i)),'.','Color',[251 177 23]/255,'Markersize',1)
            hold on
        elseif tru_id(i)>=2691 && tru_id(i)<=3910
            plot3(realx(tru_id(i)),realz(tru_id(i)),realy(tru_id(i)),'.','Color',[0 100 0]/255,'Markersize',1)
            hold on
        elseif tru_id(i)>=3911 && tru_id(i)<=4680
            plot3(realx(tru_id(i)),realz(tru_id(i)),realy(tru_id(i)),'.b','Markersize',1)
            hold on
        else
            plot3(realx(tru_id(i)),realz(tru_id(i)),realy(tru_id(i)),'.','Color',[169 169 169]/255,'Markersize',1)
            hold on
        end
    end
    
    hold off
    view(3)
    axis equal
    set(gcf,'color','w');
    hold off
    view(3)
    axis equal
    set(gcf,'color','w');

end