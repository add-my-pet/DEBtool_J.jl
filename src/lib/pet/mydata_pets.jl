## mydata_pets
# catenates mydata files for several species

##
#function [data, auxData, metaData, txtData, weights] = mydata_pets
function mydata_pets(pets)
    # created by Goncalo Marques at 2015/01/28, modified Bas Kooijman 2021/01/17
  
  ## Syntax
  # [data, auxData, metaData, txtData, weights] = <../mydata_pets.m *mydata_pets*>
  
  ## Description
  # catenates mydata files for several species
  #
  # Output
  #
  # * data: catenated data structure
  # * auxData: catenated auxiliary data structure
  # * txtData: catenated text for data
  # * metaData: catenated metadata structure
  # * weights: catenated weights structure

 global pets, pseudodata_pets, petnm
#  ["mydata_" * x for x in pets]
#  function load_modules(module_names::Vector{String})
#   for name in module_names
#       @eval using .$(Symbol(name))
#   end
# end

#  # note can't include 'i' in an eval statement - i isn't in the local scope of the evaluation
#  #expr = Meta.parse("\"mydata_\" * x * \"())\"") # parse the expression wanted
#  #fdefexpr = :(x -> $(expr)) # make it take x as an argument
#  #f = eval(fdefexpr) # define the function to evaluate it
# for i in 1:length("mydata_" * pets) # calls species mydata functions
#   #[data.(pets{i}), auxData.(pets{i}), metaData.(pets{i}), txtData.(pets{i}), weights.(pets{i})] = eval(:(include("../src/mydata_" * pets[i] * ".jl")));
#   #f(pets[i])
#   modName = Meta.parse("mydata_" * pets[1])
#   #m = :modName
#   @eval import .$modName

# @eval import .$m
#   eval(Symbol(funcname))()
#   #@get_mydata_pets(pets[i])
# end  

i = 0
for file_name in ["c:/git/DEBtool_J.jl/example/mydata_" * x * ".jl" for x in pets]
  i = i + 1
  include(file_name) # load the mydata file

  # stuff the results into new objects of style e.g. data.mypet.etc, auxData.mypet.etc
  # TO DO - simplify this!
  petnm = Symbol(pets[i])
  eval(:($petnm = data))
  @eval begin
    struct data_struct2
      $petnm
    end
    data = data_struct2($petnm)
  end
  eval(:($petnm = auxData))
  @eval begin
    struct auxData_struct2
      $petnm
    end
    auxData = auxData_struct2($petnm)
  end
  eval(:($petnm=metaData))
  @eval begin
    struct metaData_struct2
      $petnm
    end
    metaData = metaData_struct2($petnm)
  end
  eval(:($petnm=txtData))
  @eval begin
    struct txtData_struct2
      $petnm
    end
    txtData = txtData_struct2($petnm)
  end
  eval(:($petnm=weights))
  @eval begin
    struct weights_struct2
      $petnm
    end
    weights = weights_struct2($petnm)
  end
end

#[data.(pets{i}), auxData.(pets{i}), metaData.(pets{i}), txtData.(pets{i}), weights.(pets{i})] = feval(['mydata_', pets{i}]);
  # TO DO
  # if pseudodata_pets == 1 # same pseudodata for the group
  #   # remove pseudodata from species structure
  #   data = rmpseudodata(data);
  #   txtData = rmpseudodata(txtData); 
  #   weights = rmpseudodata(weights);

  #   # set pseudodata and respective weights for the group
  #   if exist('addpseudodata_group.m', 'file')
  #     [dataG, unitsG, labelG, weightsG] = addpseudodata_group;
  #   else
  #     [dataG, unitsG, labelG, weightsG] = addpseudodata([], [], [], []);
  #     fprintf('No addpseudodata_group.m found, only default pseudodata and weights are considered for the group \n')      
  #   end
    
  #   data.psd = dataG.psd;
  #   weights.psd = weightsG.psd;
  #   txtData.psd.units = unitsG.psd;
  #   txtData.psd.label = labelG.psd;
  return(data, auxData, metaData, txtData, weights)
end
