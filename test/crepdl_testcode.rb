require './crepdl'
require 'test/unit'

class TestSample < Test::Unit::TestCase
  def test_calc
    crepdl=["test.crepdl","test2.crepdl","test3.crepdl","test4.crepdl","test5.crepdl","test6.crepdl","test7.crepdl","test8.crepdl"]
    data1=[["A"],["A","B","C","D","E","F","G"],["Y"],["A","B","C","D","Y"],["X"],["A","B","C","D","E","F","G","Y"],["K","E","R","N","E","L"],["@","A","B"]]
    data2=[[],[],[],[],[],[],["H","U","L","L"],[]]
    for i in 0..(crepdl.count-1) do
      doc = REXML::Document.new(open(crepdl[i]))
      node=doc.root.name
      pass=node
      set=[]
      hull=[]
      kernel=[]
      set,pass,hull,kernel=create_tree(doc,pass,set,hull,kernel)
      assert_equal kernel.flatten, (data1[i])
      assert_equal hull.flatten, (data2[i])
    end
  end
end
