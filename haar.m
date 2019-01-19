% Grayscale Image compression using Haar transform
% Usage: haar(image_object_to_compress, compression_ratio)
% Author: Vaibhav Thakkar

function image_out = haar(image_in, compression_ratio)
    
    % 8x8 Normalised Haar Matrix
    h=[0.35355   0.35355   0.50000   0.00000   0.70711   0.00000   0.00000   0.00000
    0.35355   0.35355   0.50000   0.00000  -0.70711   0.00000   0.00000   0.00000
    0.35355   0.35355  -0.50000   0.00000   0.00000   0.70711   0.00000   0.00000
    0.35355   0.35355  -0.50000   0.00000   0.00000  -0.70711   0.00000   0.00000
    0.35355  -0.35355   0.00000   0.50000   0.00000   0.00000   0.70711   0.00000
    0.35355  -0.35355   0.00000   0.50000   0.00000   0.00000  -0.70711   0.00000
    0.35355  -0.35355   0.00000  -0.50000   0.00000   0.00000   0.00000   0.70711
    0.35355  -0.35355   0.00000  -0.50000   0.00000   0.00000   0.00000  -0.70711];

    image_haar       = haar_transform(image_in, h);
    threshold        = threshold_by_ratio(image_haar, compression_ratio);
    image_haar_lossy = lossy_compress(image_haar, threshold);
    image_out        = inverse_haar_transform(image_haar_lossy, h);
endfunction


% Function to calculate the haar transform of the image_in matrix using the 'h' matrix provided as argument
function image_haar = haar_transform(image_in, h)

    haar            = @(x) h'*x*h;
    image_size      = size(image_in);
    rows            = image_size(1,1);
    columns         = image_size(1,2);

    % Dividing input matrix into cell array, where each cell is a 8x8 matrix
    image_in_cell   = mat2cell( double(image_in) , 8*ones(1,rows/8), 8*ones(1,columns/8) );

    % Doing Haar Transform on each individual 8x8 matrix
    image_haar_cell = cellfun(haar, image_in_cell , 'UniformOutput', false) ;

    % Reconstructing the transformed matrix from the cell array
    image_haar      = cell2mat(image_haar_cell) ;

endfunction


% Function to find the threshold value of difference using compression ratio
function threshold = threshold_by_ratio(image_in, r)
    
    index=1;
    while(compression_ratio(image_in, index) < r )
        index=index+1;
    end
    index=index-1;

    while(compression_ratio(image_in, index) < r )
        index=index+0.1;
    end
    index=index-0.1;

    while(compression_ratio(image_in, index) < r )
        index=index+0.01;
    end
    threshold = index;

endfunction


% Function to calculate the compression ratio using given error threshold value
function ratio = compression_ratio(image_in, e)
    
    sz      = size(find(image_in ~= 0 ), 1);
    removed = size(find(image_in < abs(e) & image_in > -abs(e) & image_in ~=0), 1);
    ratio   = sz/(sz - removed);

endfunction


% Function to calculate the lossy compressed image from the threshold value passed
function lossy_compression_image = lossy_compress(image_in, e)
    
    image_in(image_in < abs(e) & image_in > -abs(e))  = 0;
    lossy_compression_image                           = image_in;

endfunction


% Constructing the compressed image by inverting the Haar Transformation
function image_out = inverse_haar_transform(image_haar, h)
    
    % Use this if h matrix is not normalized:
    % invhaar       = @(x) inv(h)'*x*inv(h); 
    invhaar         = @(x) h*x*h';
    image_size      = size(image_haar);
    rows            = image_size(1,1);
    columns         = image_size(1,2);
    image_haar_cell = mat2cell( double(image_haar) , 8*ones(1,rows/8), 8*ones(1,columns/8) );
    image_out_cell  = cellfun(invhaar, image_haar_cell , 'UniformOutput', false) ;
    image_out       = uint8(cell2mat(image_out_cell)) ;

endfunction