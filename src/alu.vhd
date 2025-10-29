library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity alu is
    generic (
        constant W : positive
    );
    port (
        A : in std_logic_vector (W-1 downto 0);
        B : in std_logic_vector (W-1 downto 0);
        sel_fn : in std_logic_vector (3 downto 0);
        Y : out std_logic_vector (W-1 downto 0);
        Z : out std_logic
    );
end alu;
architecture arch of alu is
    begin
        signal Au, Bu : unsigned(W-1 downto 0);
        signal As, Bs : signed(W 1 downto 0);
        signal Y_aux
 Au <= unsigned(A);
 Bu <= unsigned(B);
 As <= signed(A);
 As <= signed(B);

 funciones : process(all)
 begin 
 case sel_fn is 
 --suma A * B
when "0000" =>
 Y_aux <= Au + Bu;
-- resta A - B 
when "0001" =>
 Y_aux <= Au - Bu;
--desplazamiento a la izquierda 
when "0010"|"0011" =>
 Y_aux 
-- A menor a B en complemento a dos
when "0100"|"0101" =>
 Y_aux
when "0110"|""
 