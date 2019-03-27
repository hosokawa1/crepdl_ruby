#C:\Users\dftrt\Documents\my_project\crepdl
require 'rexml/document'
require 'set'
#Hiragana.crepdl
#cizhangyong1982.crepd
#8859-6b
#ArmenianB
doc = REXML::Document.new(open("HKI.crepdl"))
node=doc.root.name
pass=node
set=[]
hull=[]
kernel=[]
def create_tree(doc,pass,set,hull,kernel)
  #hull=[]
  #kernel=[]
  set=[]
  doc.elements.each(pass) do |element|
  #eachを使ってもう一度回す
  i=1
  print(pass,"\n")
  if(pass=="char")
    hull4=[]
    kernel4=[]
    if(element[0].to_s.match(/<\/hull>|<hull>/))
      hull << crepdl_RE(element[0].to_s)
    elsif(element[0].to_s.match(/<\/kernel>|<kernel>/))
      kernel << crepdl_RE(element[0].to_s)
    else
      kernel << crepdl_RE(element[0].to_s)
    end
    1.step((element.count-1),2) {|n|
      print("Nnum",n,element[n],"\n")
      #print(element[n].children[0].name)
      #hull3,kernel3=Hull_Kernel(element[n],hull3,kernel3)
      if(element[n].to_s.match(/<\/hull>|<hull>/))
        hull4 << crepdl_RE(element[n].to_s)
      elsif(element[n].to_s.match(/<\/kernel>|<kernel>/))
        kernel4 << crepdl_RE(element[n].to_s)
      else
        kernel4 << crepdl_RE(element[n].to_s)
      end
      #text=crepdl_RE(element[n].to_s)
      #hull << text
    }
    hull << hull4
    kernel << kernel4
      #text=crepdl_RE(element[0].to_s)
      #hull << text
  end
    until element[i]==nil do #要素の行末で終了
        print("elemet[i]=",element[i].name,"\n")
        if(element[i].name=="intersection")
          add_i_set=[]
          #kernel_add_i_set=[]
          if(element[i].children[1].name=="char")
              print((element[i].children[1].to_s).gsub(/<\/char>|<char>/,""),"\n")
              add_i_set <<  (element[i].children[1].to_s).gsub(/<\/char>|<char>/,"").split("")
              add_i_set=add_i_set.flatten
              3.step((element[i].children.length-1),2) {|m|
                add_i_set2=[]
                add_i_set2 << (element[i].children[m].to_s).gsub(/<\/char>|<char>/,"").split("")
                add_i_set2=add_i_set2.flatten
                add_i_set=add_i_set & add_i_set2
                #add_i_set << (add_i_set & element[i].children[m].to_s)
              }
                kernel << add_i_set
          end
        elsif(element[i].name=="difference")
            add_i_set=[]
            #kernel_add_i_set=[]
            if(element[i].children[1].name=="char")
                print((element[i].children[1].to_s).gsub(/<\/char>|<char>/,""),"\n")
                add_i_set <<  (element[i].children[1].to_s).gsub(/<\/char>|<char>/,"").split("")
                add_i_set=add_i_set.flatten
                3.step((element[i].children.length-1),2) {|m|
                  add_i_set2=[]
                  add_i_set2 << (element[i].children[m].to_s).gsub(/<\/char>|<char>/,"").split("")
                  add_i_set2=add_i_set2.flatten
                  add_i_set=add_i_set - add_i_set2
                  #add_i_set << (add_i_set & element[i].children[m].to_s)
                }
                  kernel << add_i_set
            end
        else
          set,pass,hull,kernel=create_characterset(doc,set,element,i,pass,hull,kernel)
        end
        print(add_i_set)
        i=i+2  #奇数 偶数は改行
    end
  end
  return set,pass,hull,kernel
end
def create_characterset(doc,set,element,i,pass,hull,kernel)
    if(element[i].name=="char" && element[i].parent.name=="union")
      set2=element[i].children.join.gsub(/[\[\]]/,"")
        #print(element[i].class,"=",set2,"=",element[i],"\n")
        hull,kernel=Hull_Kernel(element[i],hull,kernel)
        #for l in 1..(element.count-1) do
        #  print(element[l])
        #   print("a\n")
        #   l=l+2
        #end
        #print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n")
    elsif(element[i].name=="char" && element[i].parent.name=="intersection")
      add_hull,add_kernel=Hull_Kernel(element[i],hull,kernel)
      set<< (element[i].children & set)
    elsif(element[i].name=="char" && element[i].parent.name=="difference")
      set<< (element[i].children - set)
    elsif(element[i].name=="ref")
      element[i].attributes.each_attribute do |attr| #参照ファイルのURLを調べる
        b=attr.value
        doc2 = REXML::Document.new(open(b)) #crepdlファイルを開く
        node=element[i].name
        pass1=pass+"/"+node
        add_set=[]
        add_set,pass1,hull,kernel=create_tree(doc2,doc2.root.name,set,hull,kernel)
        set << add_set
      end
    elsif(element[i].name=="repertoire")
      element[i].attributes.each_attribute do |attr| #number と　registry
        print(attr.value)
        print("\n")
      end
    elsif(element[i].name=="union")
      node=element[i].name
      pass=pass+"/"+node
      add_set=[]
      add_set,pass,hull,kernel=create_tree(doc,pass,set,hull,kernel)
      set << add_set
  elsif(element[i].parent.name=="intersection")
      node=element[i].name
      pass=pass+"/"+node
      add_set=[]
      add_set,pass,hull,kernel=create_tree(doc,pass,set,hull,kernel)
      set << (add_set & set)
  elsif(element[i].parent.name=="difference")
      node=element[i].name
      pass=pass+"/"+node
      add_set=[]
      add_set,pass,hull,kernel=create_tree(doc,pass,set,hull,kernel)
      set << (add_set ^ set)
  elsif(element[i].parent.name=="alt")
  elsif(element[i].parent.name=="char")
    set=set
    element[i].children
  end
    return set,pass,hull,kernel
end

def Hull_Kernel(element,hull,kernel)
  if(element.has_elements?)
    for s in 0..(element.children.count-1) do
      if(element.children[s].name=="kernel")
        kernel << crepdl_RE(element.children[s].text)
        kernel=kernel.flatten
      elsif(element.children[s].name=="hull")
        hull << crepdl_RE(element.children[s].text)
      end
    end
  else
    for s in 0..(element.children.count-1) do
        kernel << crepdl_RE(element.children[s])
    end
  end
  return hull,kernel
end

def crepdl_RE(text)
  #文字コードの判定
  text1=text.to_s
  text=[]
  if(text1.match(/&#x.+;-&#x.+;/))
    a=text1.scan(/\h+/)
      0.step((a.count-1),2) {|i|
        for k in a[i].to_i(16)..a[i+1].to_i(16)
          text << k.chr(Encoding::UTF_8)  #256以上はエンコーディングの指定必須
          text=text.flatten
        end
      }
  elsif(text1.match(/&#x.+/))
    a=text1.scan(/\h+/)
    for n in 0..(a.count-1) do
      print("a=",a[n].to_s.to_i(16).chr(Encoding::UTF_8),"\n")
      text << a[n].to_s.to_i(16).chr(Encoding::UTF_8)
    end
  end
  #/p{is***}の判定
  if(text1=="\\p{IsHiragana}")
    text << ('あ'..'ん').to_a
  elsif(text1=="\\p{IsKatakana}")
    text << ('ァ'..'ン').to_a
  elsif(text1=="\\p{IsBasicLatin}")
    for i in 0.to_s.to_i(16).."7F".to_i(16)
      text << i.chr
    end
  end
  if(text1.match(/A-Z/))
    text << ('A'..'Z').to_a
  end
  if(text1.match(/a-z/))
    text << ('a'..'z').to_a
  end
  if(text1.match(/0-9/))
    text << ('0'..'9').to_a
  end
  if(text==[])
    return text1.split("")
  end
  return text
end

set,pass,hull,kernel=create_tree(doc,pass,set,hull,kernel)
print("----------------------------------\n")
print(set.flatten)
set=set.flatten
print("----------------------------------\n")
print("hull=",hull.flatten,"\n")
hull=hull.flatten
print("----------------------------------\n")
print("kernel=",kernel.flatten,"\n")
print("----------------------------------\n")

#################################

set1=[]
str = File.read("./sample.txt")

#data = YAML.safe_load str.gsub('"]["','"],["')
data=str.gsub(/[\r\n]/,",")
data=str.gsub(/[,]/,"")
data=data.split(/\s*/)
print(data)

#set=set.gsub(/[,]/,"")
#print(set)
#print(set.count)
#set.sub(/"["/, "")
  print("-----------------\n")
  print(hull & data)


def Exhaustive_search(set,data)
  for i in 0..set.count do
    for n in 0..data.count do
      if(set[i]==data[n])
        print(data[n])
        print("は含まれる\n")
      end
    end
  end
  print("End")
end

def RE(set,data)
  print("RE-------\n")
  #print(data.join)
  regexp = Regexp.union(set)
  print(data.join.scan(regexp))
  print("は含まれる\n")
end

def union(set,data)
  print(set & data)
  print("は含まれる\n")
end

print("-----------------\n")

print("総当たり\n")
Exhaustive_search(hull,data)
print("\nsetライブラリ\n")
union(hull,data)
print("\n正規表現\n")
RE(hull,data)
