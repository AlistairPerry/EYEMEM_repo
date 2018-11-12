function motion_out_summary (preproc_path)
% This function creates a summary of motion outliers for each subject in
% the dataset.
% Input: preprocessing root directory (subjects must be labeled according to BIDS)
% Output: summary_motionout.txt

cd(preproc_path);

d=dir('sub-*');

out={};
for i=1:length(d)
    for r=1:4
    
    sub_mat = fullfile(preproc_path, d(i).name,'preproc',['run-', num2str(r)],'motionout','motionout.txt');
    
    if exist(sub_mat,'file') == 2
    
        mo_mat = importdata(sub_mat);

        N_mo_out = size(mo_mat, 2);
        
        out=[out; {d(i).name, N_mo_out}];
    
    end
    end
end

out_tab = cell2table(out,'VariableNames',{'ID','motion_outliers'});

writetable(out_tab, fullfile(preproc_path,'summary_motionout.txt') ,'Delimiter', '\t');

end

