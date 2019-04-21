function [correlcoeff,regresscoeff,regresscoefflowerCI,regresscoeffupperCI,regressint,numtimepts,pval] = tempcorrmapnanwithintandslopeuncertainty(map1,map2)
% Function to create 2-D maps of the following:
% temporal correlation coefficients,
% regression coefficients (slopes) and 95% CI of this number, intercepts,
% number of pts used in the
% correlation calculations, and p-values of zero correlation
% between two input maps which are 3-D. The input maps must have
% 2-D spatial grids on first two dimensions and time on the
% third dimension. map1=indy var (x), map2 = dep var (y).

% check to see if two maps were passed in
if nargin~=2
    error('myRout:inargs','Wrong number of input arguments.');
end

% check to see that map1 and map2 are the same size
[j1,i1,k1] = size(map1);
if isequal(size(map1),size(map2))==0
    error('myRout:sizes','Sizes of input maps do not match.');   
end

% initialize correl coeff and num of time pts maps to decrease runtime
correlcoeff = zeros(j1,i1);
regresscoeff = zeros(j1,i1);
regresscoefflowerCI = zeros(j1,i1);
regresscoeffupperCI = zeros(j1,i1);
regressint = zeros(j1,i1);
numtimepts = zeros(j1,i1);
pval = zeros(j1,i1);

% Calculate correl and regress coeff at each x-y grid point
% and store each calculated coeff in correlcoeff and regresscoeff map.
% Same with a map of how many time points went into calculating the
% correl and regress coeffs at each x-y grid pt.
mapsptts=zeros(k1,2);
for j=1:j1
    for i=1:i1
        mapsptts(:,1)=map1(j,i,:); % ptts = point time series
        mapsptts(:,2)=map2(j,i,:); % create a matrix mapsptts with the two time series in two columns
        mapsptts = mapsptts(~any(isnan(mapsptts),2),:); % remove any rows with NaNs
        
        if isempty(mapsptts) % if mapsptts is empty matrix
            correlcoeff(j,i)=NaN;
            pval(j,i)=NaN;
        else % if mapsptts is non-empty matrix
            % calculate temp correl coeff at each x-y grid pt
            [correlcoeff(j,i),pval(j,i)] = corr(mapsptts(:,1),mapsptts(:,2));
        end
        
        % calculate regress coeff and intercept at each x-y grid pt
        if length(mapsptts(:,1))>=2 % need at least 2 points to fit line            
            % the following gets rid of situations when you have a vertical
            % best fit line, usually with 2 pts having the same x, diff y
            % value     
            if ~std(mapsptts(:,1))==1  % ~std(A) returns 1 when all elements in column vector are identical            
                regresscoeff(j,i) = NaN;
        		regressint(j,i) = NaN;
            else
                P = polyfit(mapsptts(:,1),mapsptts(:,2),1); % linear regression
                regresscoeff(j,i) = P(1); % P(1) is the regress coeff
	        	regressint(j,i) = P(2); % P(2) is the intercept
            end            
        else
            regresscoeff(j,i) = NaN;
            regressint(j,i) = NaN;
        end
        
        % calculate how many time pts of data went into calculating
        % each correl/regress coeff at each x-y grid pt; numcol=2 always
        [numtimepts(j,i),numcol] = size(mapsptts);
        
        % calculate the uncertainty/confidence interval for the slope/regress coeff
        alpha=0.05;
        X = mapsptts(:,1); Y = mapsptts(:,2);
        Yest = regresscoeff(j,i).*X + regressint(j,i);
        SSE = nansum((Y-Yest).^2); % sum of squared errors
        s2 = SSE/(numtimepts(j,i)-2);
        s = sqrt(s2);
        tstat=tinv(alpha/2,numtimepts(j,i)-2); % negative
        regresscoefflowerCI(j,i)=regresscoeff(j,i)+tstat*s;
        regresscoeffupperCI(j,i)=regresscoeff(j,i)-tstat*s;

        clear mapsptts X Y Yest SSE s2 s tstat;
    end
end
