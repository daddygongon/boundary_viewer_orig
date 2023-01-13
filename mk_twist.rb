#+name: mk_twist.rb
#+begin_src ruby -n
require 'scanf'
require 'matrix'
include Math

class MkTwist
  def initialize(sigma)
    @sigma = sigma
    read_poscar_0()
    expand_lat(2)
    @theta = atan2(1.0, @sigma)
    @angle = @theta/PI*180.0
    rotate_lat(@theta)
    rotate_pos(@theta)
  end
  def read_poscar_0
    lines = File.readlines("POSCAR_0")
    @lat = Array.new(3){ Array.new(3, 0.0) }
    3.times{ |i| @lat[i][i] = lines[i+2].scanf("%f %f %f")[i] }
    @n_atom = lines[5].scanf("%d")[0]
    @pos = Array.new(@n_atom){ Array.new(3, 0.0) }
    @n_atom.times do |i|
      poss = lines[i+7].scanf("%f %f %f")
      3.times{|j| @pos[i][j] = poss[j]}
    end
  end
  def print_poscar
    cont = "n_sigma=%4d, theta=%8.4f, angle=%8.4f, " % [@sigma, @theta, @angle]
    cont << "twist boundary\n4.0414\n"
    @lat.each {|x| cont << sprintf("%15.10f %15.10f %15.10f\n", x[0], x[1], x[2])}
    n_atom = @rotate_pos.size
    cont << "#{n_atom}\nDirect\n"
    @rotate_pos.sort!{|a,b| a[2] <=> b[2]}
    @rotate_pos.each do |x|
      cont << sprintf("%15.10f %15.10f %15.10f\n", x[0], x[1], x[2])
    end
    return cont
  end
  def save_poscar_file(dir)
    File.write(File.join(dir,'POSCAR'), print_poscar)
  end
  def expand_lat(n_lat=2)
    @lat[2][2] = 4*@lat[2][2] # z-axis * 4
    @expand_pos = []
    [*(-2..4)].each do |i|
      [*(-2..4)].each do |j|
        [*(0..3)].each do |k|
          @pos.each do |pos|
            sel = [i,j,k]
            @expand_pos << [0,1,2].inject([]) do |tmp, m|
              tmp << (pos[m]+sel[m])/@lat[m][m]
            end
          end
        end
      end
    end
    @n_atom = @expand_pos.size
  end
  def r_matrix(theta)
    Matrix.rows([[cos(theta),-sin(theta),0.0],
                 [sin(theta),cos(theta),0.0],
                 [0.0,0.0,1.0]])
  end
  def rotate_lat(theta)
    div = (@sigma % 2 == 0)? 1.0 : 2.0
    @lat[0] = (r_matrix(theta)*Vector[@sigma/div,-1.0/div,0.0]).to_a
    @lat[1] = (r_matrix(theta)*Vector[1.0/div,@sigma/div,0.0]).to_a
  end

  def add_rotate_pos(theta,pos)
    pos_new = (r_matrix(theta)*Vector[*pos]).to_a
    if pos_new[0]>=0 and pos_new[0]< @x_lat and
        pos_new[1]>=0 and pos_new[1]< @y_lat
      x,y,z=pos_new.to_a
      @rotate_pos << [x/@x_lat, y/@y_lat, z]
    end
  end
  def rotate_pos(theta, pos_z='all')
    @rotate_pos = []
    @expand_pos.each do |pos|
      @x_lat = @lat[0][0]
      @y_lat = @lat[1][1]
      pos[2] < 0.5 ? add_rotate_pos(theta,pos) :
        add_rotate_pos(-theta,pos)
    end
  end
end

sigma = ARGV[0] || '3'
twist = MkTwist.new(sigma.to_f)
puts twist.print_poscar()
twist.save_poscar_file('.')
twist.save_poscar_file('sketch_twist/data')
#+end_src

