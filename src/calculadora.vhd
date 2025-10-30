library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Top: panel de 8 llaves + registros A/B + ALU + MUX + 7 segmentos
entity panel_top is
  generic (
    W : positive := 4   -- ancho de A, B y ALU
  );
  port(
    clk    : in  std_logic;
    x      : in  std_logic_vector(7 downto 0);  -- switches
    S      : out std_logic_vector(6 downto 0)   -- S(6)=Sg ... S(0)=Sa (igual que deco_hexa)
  );
end entity;

architecture rtl of panel_top is
  ------------------------------------------------------------------
  -- Declaración de componentes (tus módulos)
  ------------------------------------------------------------------
  component alu is
    generic ( W : positive );
    port (
      A      : in  std_logic_vector (W-1 downto 0);
      B      : in  std_logic_vector (W-1 downto 0);
      sel_fn : in  std_logic_vector (3 downto 0);
      Y      : out std_logic_vector (W-1 downto 0);
      Z      : out std_logic
    );
  end component;

  component deco_hexa is
    port(
      D : in std_logic_vector (3 downto 0);
      S : out std_logic_vector (6 downto 0) -- Sg..Sa
    );
  end component;

  component detector_flanco is
    port (
      clk     : in std_logic;
      entrada : in std_logic;
      pulso   : out std_logic
    );
  end component;

  ------------------------------------------------------------------
  -- Señales internas
  ------------------------------------------------------------------
  -- sincronización simple a clk para las 8 llaves
  signal xs1, xs2 : std_logic_vector(7 downto 0);
  signal xs       : std_logic_vector(7 downto 0);

  signal nib          : std_logic_vector(3 downto 0);      -- x(3..0)
  signal A_reg, B_reg : std_logic_vector(W-1 downto 0);
  signal Y_res        : std_logic_vector(W-1 downto 0);
  signal Z_flag       : std_logic;

  signal ldA_p, ldB_p, exec_p : std_logic;                 -- pulsos de flanco

  signal disp_nib : std_logic_vector(3 downto 0);
begin
  ------------------------------------------------------------------
  -- (1) Sincronización 2FF de todos los switches (evita metaestabilidad)
  ------------------------------------------------------------------
  process(clk) begin
    if rising_edge(clk) then
      xs1 <= x;
      xs2 <= xs1;
    end if;
  end process;
  xs  <= xs2;
  nib <= xs(3 downto 0);

  ------------------------------------------------------------------
  -- (2) Detectores de flanco para cargar A, B y ejecutar (A←Y)
  ------------------------------------------------------------------
  u_flA : detector_flanco port map(clk => clk, entrada => xs(4), pulso => ldA_p);
  u_flB : detector_flanco port map(clk => clk, entrada => xs(5), pulso => ldB_p);
  u_flE : detector_flanco port map(clk => clk, entrada => xs(6), pulso => exec_p);

  ------------------------------------------------------------------
  -- (3) Registros A y B
  --     - Carga de A/B con los 4 LSB de las llaves (extensión con ceros si W>4)
  --     - 'exec_p' tiene prioridad: A <- Y
  ------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if ldA_p = '1' then
        A_reg <= (others => '0');
        A_reg(3 downto 0) <= nib;
      end if;

      if ldB_p = '1' then
        B_reg <= (others => '0');
        B_reg(3 downto 0) <= nib;
      end if;

      if exec_p = '1' then
        A_reg <= Y_res;  -- write-back del resultado de la ALU
      end if;
    end if;
  end process;

  ------------------------------------------------------------------
  -- (4) ALU (tu implementación)
  ------------------------------------------------------------------
  u_alu : alu
    generic map ( W => W )
    port map(
      A      => A_reg,
      B      => B_reg,
      sel_fn => nib,       -- selector de función desde x(3..0)
      Y      => Y_res,
      Z      => Z_flag
    );

  ------------------------------------------------------------------
  -- (5) MUX de visualización (x(7)=0→A, x(7)=1→B). Mostramos LSB(3..0).
  ------------------------------------------------------------------
  disp_nib <= B_reg(3 downto 0) when xs(7) = '1' else A_reg(3 downto 0);

  ------------------------------------------------------------------
  -- (6) Decodificador hexa → 7 segmentos (Sg..Sa)
  ------------------------------------------------------------------
  u_hex : deco_hexa
    port map(
      D => disp_nib,
      S => S
    );

  -- Opcional: podés sacar Z_flag a un LED/DP si tu placa lo permite.
end architecture;
