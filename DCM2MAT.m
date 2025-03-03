function [ROI, Boundaries, MRI] = DCM2MAT(Group, ID)
% Function to convert MR images, ROI, and lesion boundaries to matrices
% Input:
%   Group - Patient group (Acute/Chronic)
%   ID    - Subject ID
% The images are categorized into two groups:
% 1.Acute (<3 days post-stroke, n = 6) and,
% IDs: 1f1, 1f2, 1f3, 2f2, 3f1, 3f2 
% 2.Chronic (≥28 days post-stroke, n = 4).
% IDs: 1f1, 1f2, 2f1, 2f2
% Output:
%   MRI         - MRI data
%   ROI         - Region of Interest
%   Boundaries  - Lesion boundaries


% Define file paths
Filename = strcat ("MRI_",ID,".dcm");
FileDirection = strcat ("MRI_Dataset\",Group,"\ID_",ID,"\",Filename); 

% Read DICOM volume and preprocess
mri = dicomreadVolume(FileDirection);

% Preallocate memory for performance
mri = squeeze(mri(:,:,1,:));
ROI = ones(size(mri,1)*2,size(mri,2)*2, size(mri,3));

for Sectioni = 1:size(mri,3)
    % Resize the MRI slice
    MRI(:,:,Sectioni) = imresize(squeeze(mri(:,:,Sectioni)),2);
    Boundries_sectioni = MRI(:,:,Sectioni);

    % Read ROI file
    Filename = strcat ("\RoiSet_",ID,"\Section_",num2str(Sectioni),".roi");
    cstrFilenames = strcat ("MRI_Dataset\",Group,"\ID_",ID,Filename);
    sROI = ReadImageJROI(cstrFilenames);

    % Extract X and Y coordinates
    YXCoordinates_Sectioni = (sROI.mnCoordinates)*2;
    X = YXCoordinates_Sectioni(:,2);
    Y = YXCoordinates_Sectioni(:,1);

    % Create binary ROI mask from coordinates
    ROI (:,:,Sectioni) = roipoly(ROI(:,:,Sectioni), Y, X);

    % Draw boundaries
    for n=1:size(YXCoordinates_Sectioni,1)
        Boundries_sectioni(X(n),Y(n))=0;
    end
    Boundaries (:,:,Sectioni) = Boundries_sectioni;

    
end
end