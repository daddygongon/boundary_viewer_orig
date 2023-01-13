

# intro

twist粒界の作成手順

| ![img](https://nishitani.qiita.com/files/e226ace7-0817-4748-b98d-7bb01f018aa0.png)|
|:--------------------------------------------------------------------------|
| モデル                                                                    |


# viewer

    open sketch_twist.pde

でdata/POSCARを表示．

以下の表示は粒界最近傍の２層を取り出して表示している．見やすいようにユニットセルを囲い，拡張している．

| ![img](https://nishitani.qiita.com/files/98c3162d-b1d7-6944-128c-38abd6589819.png)|
|:------------------------------------------------------------------------|
| sketch\_twist.pdeでの表示結果                                           |

表示の体裁を整えるoptionsは，mk\_twistではなく，viewerに実装すべき．

三面図で表示させてみようか．．．

下記のようにして描画範囲を選択すると，見やすいんですが．．．

```ruby
1:   poss.each {|pos| pos[2] < 0.5 ? pos0 << pos : pos1 << pos }

2:   poss.each do |pos|
     if (pos[2]/0.125)%2==1
       pos0 << pos
     else
       pos1 << pos
     end
   end
```

詳しい解説やコードは[twist viewer](https://nishitani.qiita.com/daddygongon/items/73a73599539920cd7983)に記した．


# modeler

1.  100の基本格子を2倍，2倍で拡張する．
2.  それを縦に積む．2layer.
3.  そいつを捻る．


## mk\_twist.rb

```ruby
  3require 'scanf'
  4require 'matrix'
  5include Math
  6
  7class MkTwist
  8  attr_accessor :lat, :pos, :n_atom, :rotate_pos, :expand_pos
  9  def initialize...end
 17  def read_poscar_0...end
 33  def mod_pos(poss)...end
 49  def print_poscar...end
 65  def print_poscar_final(dir)...end
 69  def expand_lat(zz=false)...end
 87  def r_matrix(theta)...end
 92  def rotate_lat(theta)...end
 97  def rotate_pos(theta, pos_z='all')...end
122end
123
124twist = MkTwist.new
125puts twist.print_poscar()
126twist.print_poscar_final('.')
127twist.print_poscar_final('sketch_twist/data')
```

```ruby:mk_twist.rb
 1  require 'scanf'
 2  require 'matrix'
 3  include Math
 4  
 5  class MkTwist
 6    def initialize(sigma)
 7      @sigma = sigma
 8      read_poscar_0()
 9      expand_lat(2)
10      @theta = atan2(1.0, @sigma)
11      @angle = @theta/PI*180.0
12      rotate_lat(@theta)
13      rotate_pos(@theta)
14    end
15    def read_poscar_0
16      lines = File.readlines("POSCAR_0")
17      @lat = Array.new(3){ Array.new(3, 0.0) }
18      3.times{ |i| @lat[i][i] = lines[i+2].scanf("%f %f %f")[i] }
19      @n_atom = lines[5].scanf("%d")[0]
20      @pos = Array.new(@n_atom){ Array.new(3, 0.0) }
21      @n_atom.times do |i|
22        poss = lines[i+7].scanf("%f %f %f")
23        3.times{|j| @pos[i][j] = poss[j]}
24      end
25    end
26    def print_poscar
27      cont = "n_sigma=%4d, theta=%8.4f, angle=%8.4f, " % [@sigma, @theta, @angle]
28      cont << "twist boundary\n4.0414\n"
29      @lat.each {|x| cont << sprintf("%15.10f %15.10f %15.10f\n", x[0], x[1], x[2])}
30      n_atom = @rotate_pos.size
31      cont << "#{n_atom}\nDirect\n"
32      @rotate_pos.sort!{|a,b| a[2] <=> b[2]}
33      @rotate_pos.each do |x|
34        cont << sprintf("%15.10f %15.10f %15.10f\n", x[0], x[1], x[2])
35      end
36      return cont
37    end
38    def save_poscar_file(dir)
39      File.write(File.join(dir,'POSCAR'), print_poscar)
40    end
41    def expand_lat(n_lat=2)
42      @lat[2][2] = 4*@lat[2][2] # z-axis * 4
43      @expand_pos = []
44      [*(-2..4)].each do |i|
45        [*(-2..4)].each do |j|
46  	[*(0..3)].each do |k|
47  	  @pos.each do |pos|
48  	    sel = [i,j,k]
49  	    @expand_pos << [0,1,2].inject([]) do |tmp, m|
50  	      tmp << (pos[m]+sel[m])/@lat[m][m]
51  	    end
52  	  end
53  	end
54        end
55      end
56      @n_atom = @expand_pos.size
57    end
58    def r_matrix(theta)
59      Matrix.rows([[cos(theta),-sin(theta),0.0],
60  		 [sin(theta),cos(theta),0.0],
61  		 [0.0,0.0,1.0]])
62    end
63    def rotate_lat(theta)
64      div = (@sigma % 2 == 0)? 1.0 : 2.0
65      @lat[0] = (r_matrix(theta)*Vector[@sigma/div,-1.0/div,0.0]).to_a
66      @lat[1] = (r_matrix(theta)*Vector[1.0/div,@sigma/div,0.0]).to_a
67    end
68  
69    def add_rotate_pos(theta,pos)
70      pos_new = (r_matrix(theta)*Vector[*pos]).to_a
71      if pos_new[0]>=0 and pos_new[0]< @x_lat and
72  	pos_new[1]>=0 and pos_new[1]< @y_lat
73        x,y,z=pos_new.to_a
74        @rotate_pos << [x/@x_lat, y/@y_lat, z]
75      end
76    end
77    def rotate_pos(theta, pos_z='all')
78      @rotate_pos = []
79      @expand_pos.each do |pos|
80        @x_lat = @lat[0][0]
81        @y_lat = @lat[1][1]
82        pos[2] < 0.5 ? add_rotate_pos(theta,pos) :
83  	add_rotate_pos(-theta,pos)
84      end
85    end
86  end
87  
88  sigma = ARGV[0] || '3'
89  twist = MkTwist.new(sigma.to_f)
90  puts twist.print_poscar()
91  twist.save_poscar_file('.')
92  twist.save_poscar_file('sketch_twist/data')
```


## results

結果は次の通り．さらに，./POSCAR, ./sketch\_twist/data/POSCARに保存される．また，

    > ruby mk_twist.rb 3
    n_sigma=   3, theta=  0.3218, angle= 18.4349, twist boundary
    4.0414
       1.5811388301    0.0000000000    0.0000000000
       0.0000000000    1.5811388301    0.0000000000
       0.0000000000    0.0000000000    4.0000000000
    40
    Direct
       0.2000000000    0.4000000000    0.0000000000
       0.0000000000    0.0000000000    0.0000000000
       0.4000000000    0.8000000000    0.0000000000
       0.8000000000    0.6000000000    0.0000000000
       0.6000000000    0.2000000000    0.0000000000
       0.9000000000    0.3000000000    0.1250000000
       0.5000000000    0.5000000000    0.1250000000
    ...

引数が省略された場合は，3が入る．n\_sigmaの値を使ってviewerのtilt\_rectが描画される．

えっと，あまりにsite\_numberが飛びすぎるので，sortをかけるバージョンが要りそう．これは，print\_poscarの中で，

```ruby
@rotate_pos.sort!{|a,b| a[2] <=> b[2]}
```

で実行している．


## rotate\_lat

twist boundaryを作るときに，keyとなるのはrotate\_lat関数です．これで，ユニットセルの軸を$&theta;$radian回転させています．

```ruby
def rotate_lat(theta)
  @lat[0] = (r_matrix(theta)*Vector[@sigma/2.0,-1.0/2.0,0.0]).to_a
  @lat[1] = (r_matrix(theta)*Vector[1.0/2.0,@sigma/2.0,0.0]).to_a
end
```

最初にユニットセルを2x2倍に拡張しているので，その<3/2, -1/2>と<1/2, 3/2>POSCAR基本ベクトルは


# 発展形

mk\_twist.rbを拡張して5x5および7x7を作ってみた．どこまであっているかは検討する必要ある．また，近づきすぎた原子を削除する必要があるかも．VASPでじっくり検討すべき．あるいは，文献を探す．

| ![img](https://nishitani.qiita.com/files/637806f6-be1b-0fb2-e1af-d4899d932760.png)| ![img](https://nishitani.qiita.com/files/e9c49057-99dc-7a58-8eb6-615db95fd253.png)|
|---------------------------------------------------------------------------:|-------------------------------------------------------------------------:|
| 5x5                                                                        | 7x7                                                                      |

