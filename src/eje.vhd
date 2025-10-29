library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

architecture Behavioral_VHDL2008 of ALU_W_bits is
    -- Señales internas de diferentes tipos para manejar las operaciones
    signal A_unsigned, B_unsigned : unsigned(W-1 downto 0);
    signal A_signed, B_signed     : signed(W-1 downto 0);
    signal Y_result_slv           : std_logic_vector(W-1 downto 0);

begin

    -- Conversión de entradas a tipos numéricos para aritmética y relacionales
    A_unsigned <= unsigned(A);
    B_unsigned <= unsigned(B);
    A_signed   <= signed(A);
    B_signed   <= signed(B);
    
    -- Proceso secuencial sensible a las entradas para la lógica combinacional de la ALU
    process (A, B, sel_fn) is
        variable V_Y_output     : std_logic_vector(W-1 downto 0);
        variable V_shift_amount : natural range 0 to W-1;
    begin
        
        -- Obtener la cantidad de desplazamiento (B) como un entero natural.
        if B_unsigned > to_unsigned(W, W) then
            V_shift_amount := W;
        else
            V_shift_amount := to_integer(B_unsigned);
        end if;

        -- El CASE utiliza el selector de función con el carácter de indiferencia ('-').
        case sel_fn is
            
            -- 0000: A + B
            when "0000" =>
                V_Y_output := std_logic_vector(A_unsigned + B_unsigned);
            
            -- 0001: A - B
            when "0001" =>
                V_Y_output := std_logic_vector(A_unsigned - B_unsigned);
                
            [cite_start]-- 001-: A << B (Desplazamiento a la izquierda lógico) [cite: 8]
            when "001-" =>
                -- Shift Logical Left (SLL) con unsigned
                V_Y_output := std_logic_vector(shift_left(A_unsigned, V_shift_amount));
                
            [cite_start]-- 010-: A < B (Complemento a 2 / Signed) [cite: 5]
            when "010-" => 
                if A_signed < B_signed then
                    V_Y_output := (0 => '1', others => '0'); -- Resultado '1' (True)
                else
                    V_Y_output := (others => '0'); -- Resultado '0' (False)
                end if;
            
            [cite_start]-- 011-: A < B (Binario Natural / Unsigned) [cite: 5]
            when "011-" => 
                if A_unsigned < B_unsigned then
                    V_Y_output := (0 => '1', others => '0'); -- Resultado '1' (True)
                else
                    V_Y_output := (others => '0'); -- Resultado '0' (False)
                end if;
            
            [cite_start]-- 100-: A XOR B [cite: 5]
            when "100-" =>
                V_Y_output := A xor B;
                
            [cite_start]-- 1010: A >> B (Binario Natural / Logical Right Shift) [cite: 5, 8]
            when "1010" =>
                -- Shift Logical Right (SRL) con unsigned
                V_Y_output := std_logic_vector(shift_right(A_unsigned, V_shift_amount));
            
            [cite_start]-- 1011: A >> B (Complemento a 2 / Arithmetic Right Shift) [cite: 5]
            when "1011" =>
                -- Shift Arithmetic Right (SRA) con signed
                V_Y_output := std_logic_vector(shift_right(A_signed, V_shift_amount));
                
            [cite_start]-- 110-: A OR B [cite: 5]
            when "110-" =>
                V_Y_output := A or B;
            
            [cite_start]-- 111-: A AND B [cite: 5]
            when "111-" =>
                V_Y_output := A and B;
                
            -- Caso por defecto (otros valores no definidos)
            when others =>
                V_Y_output := (others => 'X');
                
        end case;

        -- Asignación de la salida principal
        Y_result_slv <= V_Y_output;

    end process;
    
    ---
    
    [cite_start]-- Lógica para la salida Z (Indicación de resultado cero, Z=1 si Y=0) [cite: 7]
    -- Asignación concurrente (fuera del proceso)
    Z <= '1' when Y_result_slv = (Y_result_slv'range => '0') else '0';
    
    -- Conexión de la salida
    Y <= Y_result_slv;

end architecture Behavioral_VHDL2008;