library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use work.all;

entity detector_flanco_tb is
end entity detector_flanco_tb;

architecture sim of detector_flanco_tb is

    -- Constante para el período del reloj 
    constant CLK_PERIODO : time := 100 ns;

    -- Señales para conectar a detector
    signal clk      : std_logic := '0'; -- Reloj
    signal entrada  : std_logic := '0'; --(entrada)
    signal pulso    : std_logic; -- Pulso (salida)

begin

    dut : entity work.detector_flanco
        port map (
            clk      => clk,
            entrada  => entrada,
            pulso    => pulso
        );

    -- Proceso Generador de Reloj
    clk_gen_proc : process
    begin
        -- Genera un ciclo de reloj
        clk <= '0';
        wait for CLK_PERIODO / 2; -- Espera 5 ns
        clk <= '1';
        wait for CLK_PERIODO / 2; -- Espera 5 ns
    end process clk_gen_proc;

    estimulo_proc : process
    begin
        report "Inicio de la simulación del detector de flanco";
        
        -- Estado inicial
        entrada <= '0';
        wait for CLK_PERIODO * 5; 

        report "Prueba 1: Señal";
        entrada <= '1';
        wait for CLK_PERIODO * 5;

        report "Prueba 2: Sin señal";
        entrada <= '0';
        wait for CLK_PERIODO * 5; 

        
        report "Prueba 3: Pulso rápido";
        entrada <= '1';
        wait for CLK_PERIODO;
        entrada <= '0';
        wait for CLK_PERIODO * 5; 
        
        -- Fin de la simulación
        report "Simulación terminada.";
        finish; 

    end process;

end architecture sim;