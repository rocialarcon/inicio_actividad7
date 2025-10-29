-- alu.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  generic ( W : positive := 8 );
  port (
    A, B   : in  std_logic_vector(W-1 downto 0);
    sel_fn : in  std_logic_vector(3 downto 0);
    Y      : out std_logic_vector(W-1 downto 0);
    Z      : out std_logic
  );
end entity;

architecture rtl of alu is
  constant SHW : natural := integer(ceil(log2(real(W))));  -- si tu síntesis no acepta, pásalo por generic
  signal Au, Bu : unsigned(W-1 downto 0);
  signal As, Bs : signed(W-1 downto 0);
  signal Yu     : unsigned(W-1 downto 0);
  signal Bsh    : natural;
begin
  Au <= unsigned(A);
  Bu <= unsigned(B);
  As <= signed(A);
  Bs <= signed(B);

  -- cantidad de desplazamiento: usar los mínimos bits de B necesarios
  Bsh <= to_integer(unsigned(B(min(SHW-1, W-1) downto 0)));

  process(Au, Bu, As, Bs, sel_fn, Bsh)
    variable tmp : unsigned(W-1 downto 0);
  begin
    tmp := (others => '0');

    -- Casos exactos 0000 y 0001
    if    sel_fn = "0000" then
      tmp := Au + Bu;                               -- A+B

    elsif sel_fn = "0001" then
      tmp := Au - Bu;                               -- A-B

    -- 001-  =>  0010 o 0011 : A << B
    elsif sel_fn(3 downto 1) = "001" then
      tmp := shift_left(Au, Bsh);

    -- 010-  => signed less-than
    elsif sel_fn(3 downto 1) = "010" then
      if As < Bs then
        tmp := (others => '0'); tmp(0) := '1';
      else
        tmp := (others => '0');
      end if;

    -- 011-  => unsigned less-than
    elsif sel_fn(3 downto 1) = "011" then
      if Au < Bu then
        tmp := (others => '0'); tmp(0) := '1';
      else
        tmp := (others => '0');
      end if;

    -- 1010 => SRL (unsigned, lógico)
    elsif sel_fn = "1010" then
      tmp := shift_right(Au, Bsh);

    -- 1011 => SRA (signed, aritmético)
    elsif sel_fn = "1011" then
      tmp := std_logic_vector(shift_right(signed(A), Bsh)) when false else (others=>'0'); -- placeholder
      -- Implementación correcta de SRA:
      tmp := unsigned( As sra Bsh );

    -- 100- => XOR
    elsif sel_fn(3 downto 1) = "100" then
      tmp := Au xor Bu;

    -- 110- => OR
    elsif sel_fn(3 downto 1) = "110" then
      tmp := Au or Bu;

    -- 111- => AND
    elsif sel_fn(3 downto 1) = "111" then
      tmp := Au and Bu;

    else
      tmp := (others => '0');
    end if;

    Yu <= tmp;
  end process;

  Y <= std_logic_vector(Yu);
  Z <= '1' when Yu = 0 else '0';
end architecture;
