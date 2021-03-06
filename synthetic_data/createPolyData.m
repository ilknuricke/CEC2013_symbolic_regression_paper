function models = createPolyData(dimensions,maxorder,numModels,datadir)

digits 4
format SHORT 

%how many dimensions
numVariables = dimensions;

variables={};
coefficients = {};

%fstr='f=(';
fstr='(';
for i=1:numVariables,
    variables{i}=strcat('X',num2str(i));
    coefficients{i}=strcat('a',num2str(i));
    syms(variables{i});
    syms(coefficients{i});
    fstr=strcat(fstr,coefficients(i),'*',variables{i},'+');
end;

coefficients{numVariables+1} = strcat('a',num2str(numVariables+1));
syms(coefficients{numVariables+1});
fstr=strcat(fstr,coefficients{numVariables+1},')^order');
syms('order');
%f=(a*X+b*Y+c)^order


%syms('x','y','a','b','order');
%f=(a*x+b)^order;


for order=1:maxorder;
 for m=1:numModels,
  for base=order:-1:1,  
  
 for i=1:numVariables+1,
    eval(strcat(coefficients{i},'=',num2str(rand(1,1)*2 - 1),';')); %% coefficients between -1,1
 end;
   
expression_str=char(vpa(expand((eval(char(fstr))))));
expression_str=regexprep(expression_str,'- ','-');
expression_str=regexprep(expression_str,'+ ','+');

for nv=1:numVariables,
   for no=2:order, 
     multform='';
     for mm=1:no-1,
       multform=strcat(multform,variables{nv},'*');
     end;
     multform=strcat(multform,variables{nv});
     expression_str=regexprep(expression_str,strcat(variables{nv},'\^',num2str(no)),multform);
   end;
end


expression_str

atoms=strread(expression_str,'%s');
numAtoms=size(atoms,1);

%find the constant
for i =1:numAtoms,
  if isempty(regexp(atoms{i},'^[\+,\-]','match'))
      atoms{i}=strcat('+',atoms{i});
  end;
  
   if (isempty(strfind(atoms{i},'X')))
       constant=atoms{i}; 
  end;
end; %end of find constant

constant 
ff={};
%added=1;

for i=1:base,
 atomsPerOrder(i).atoms='';
end;
for t=1:base,
    numAtoms
%add expressions with base interactions...
for i =1:numAtoms,
  if (size(regexp(atoms{i},'\*','match'),2)==(order-t+1))
    %ff{added}=atoms{i};
       %added=added+1;
       %atomsPerOrder(t).atoms=strvcat(atomsPerOrder(t).atoms,atoms{i});
       atomsPerOrder(t).atoms=char(atomsPerOrder(t).atoms,atoms{i});
  end;
end;
end;
exp='';
exp=strcat(exp,char(constant));

atomsPerOrder(1)
    
%for k=1:size(ff,2), exp=strcat(exp,char(ff{k})); end; 
%added=1;
for i=1:base,
    i
    atomsPerOrder(i).atoms
   if (~isempty(atomsPerOrder(i).atoms)),
     whichOne= floor(rand()*size(atomsPerOrder(i).atoms,1)) + 1
     atomsPerOrder(i).atoms(1,:)
     addedbase=atomsPerOrder(i).atoms(whichOne,:)
     exp = strcat(exp,addedbase);
     %added=added+1;
   end;
end;

%disp(sprintf('%d %d %s',order,order-base+1,exp));
%disp(exp);
exp 
models{order,base,m}=strcat('y=',char(vpa(exp)),';');   

myregexp=regexp(char(models{order,base,m}), '[[[\-\+]\d\.[\d]*(e-)[\*]?[[XY][^][\d]]*]*[\s]?[[\-\+]\d\.[\d]*(e-)[\*]?[[XY][^][\d]]*]*]*','match');
if (max(size(myregexp)) > 1) 
    disp('error... something wrong with expression');
    disp(myregexp);
    return;
end; 

end; %end of base
end; %end of one model
end; %end of one order
save(strcat(datadir,'/',num2str(dimensions),'D_',num2str(maxorder),'order_',num2str(numModels),'_models'),'models');



%cd (strcat('/Users/ilknuricke/Desktop/gptips1.0/DATA_1D/'));
cd(datadir);


for order=1:maxorder,
    for base=1:1:order,
      for m=1:numModels,
          
trainX=zeros(2500,numVariables);
trainY=zeros(2500,1);

validationX=zeros(1250,numVariables);
validationY=zeros(1250,1);

testX = zeros(1250,numVariables);
testY = zeros(1250,1);

%create input data at random
for i=1:numVariables,
    eval(strcat(variables{i},'=rand(5000,1);')); %% coefficients between -1,1
    eval(strcat('x(:,i)=',variables{i},';'));
 end;
 
models
mymodel = models{order,base,m};
thismodel=char(mymodel);
thismodel=regexprep(thismodel,'*','.*');
thismodel=regexprep(thismodel,'\^','.^')

eval(thismodel);

a=1; 
b=1;
for i=1:4:5000, 

    trainX(a,:)=x(i,:); 
    trainY(a,:)=y(i,:);
    
    trainX(a+1,:)=x(i+1,:);
    trainY(a+1,:)=y(i+1,:);
    a=a+2;
    
    validationX(b,:) = x(i+2,:);
    validationY(b,:) = y(i+2,:);
    
    testX(b,:) = x(i+3,:);
    testY(b,:) = y(i+3,:);
    
    b=b+1;
    
end;

%header{1} ='X';
%header{2} = 'Y';
header=variables;
header{numVariables+1}='Y';

csvwrite(strcat('train_',num2str(order),'_',num2str(base),'_',num2str(m),'_','in.csv'),trainX(:,:)');
csvwrite(strcat('train_',num2str(order),'_',num2str(base),'_',num2str(m),'_','out.csv'),trainY(:,:)');

csvwrite(strcat('train_',num2str(order),'_',num2str(base),'_',num2str(m),'_','x.csv'),trainX(:,:));
csvwrite(strcat('train_',num2str(order),'_',num2str(base),'_',num2str(m),'_','y.csv'),trainY(:,:));

csvwrite(strcat('validation_',num2str(order),'_',num2str(base),'_',num2str(m),'_','in.csv'),validationX(:,:)');
csvwrite(strcat('validation_',num2str(order),'_',num2str(base),'_',num2str(m),'_','out.csv'),validationY(:,:)');

csvwrite(strcat('validation_',num2str(order),'_',num2str(base),'_',num2str(m),'_','x.csv'),validationX(:,:));
csvwrite(strcat('validation_',num2str(order),'_',num2str(base),'_',num2str(m),'_','y.csv'),validationY(:,:));

csvwrite(strcat('test_',num2str(order),'_',num2str(base),'_',num2str(m),'_','in.csv'),testX(:,:)');
csvwrite(strcat('test_',num2str(order),'_',num2str(base),'_',num2str(m),'_','out.csv'),testY(:,:)');

csvwrite(strcat('test_',num2str(order),'_',num2str(base),'_',num2str(m),'_','x.csv'),testX(:,:));
csvwrite(strcat('test_',num2str(order),'_',num2str(base),'_',num2str(m),'_','y.csv'),testY(:,:));

csvwrite(strcat(num2str(order),'_',num2str(base),'_',num2str(m),'_training.csv'),[trainX trainY]);
csvwrite(strcat(num2str(order),'_',num2str(base),'_',num2str(m),'_validation.csv'),[validationX validationY]);
csvwrite(strcat(num2str(order),'_',num2str(base),'_',num2str(m),'_test.csv'),[testX testY]);

save(strcat(datadir,'/',num2str(order),'_',num2str(base),'_',num2str(m),'_dataset'),'header','trainX','trainY','validationX','validationY','testX','testY','mymodel');

clear trainX;
clear trainY;

clear validationX;
clear validationY;

clear testX;
clear testY;

clear y;

      end;
    end;
end;


       




digits 32

