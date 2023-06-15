## mydata_pets
# catenates mydata files for several species

##
#function [data, auxData, metaData, txtData, weights] = mydata_pets
struct data_struct2
  mypet
end
struct auxData_struct2
  mypet
end
struct metaData_struct2
  mypet
end
struct txtData_struct2
  mypet
end
struct weights_struct2
  mypet
end
function mydata_pets()
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

  include("c:/git/DEBtool_J.jl/example/mydata.jl") # load the mydata file
  data_mod = DEBtool_J.data_mod
  data = data_struct2(DEBtool_J.data)
  auxData = auxData_struct2(DEBtool_J.auxData)
  metaData = metaData_struct2(DEBtool_J.metaData)
  txtData = txtData_struct2(DEBtool_J.txtData)
  weights = weights_struct2(DEBtool_J.weights)
  return(data_mod, data, auxData, metaData, txtData, weights)
end
