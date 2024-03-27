library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_lock is
    port (
        clk : in std_logic;
        reset : in std_logic;
        config : in std_logic;
        valid : in std_logic;
        entrada : in std_logic_vector(7 downto 0);
        configurado : out std_logic;
        tranca : out std_logic;
        alarme : out std_logic
    );
end digital_lock;

architecture behavior of digital_lock is
    type state_type is (desconfigurado, configuracao, operacao, erro);
    type senha_array is array(0 to 2) of std_logic_vector(7 downto 0);
    signal state : state_type;
    signal senha : senha_array;
    signal tentativas : integer range 0 to 3;
begin
    process (clk, reset)
    begin
        if reset = '1' then
            state <= desconfigurado;
            configurado <= '0';
            tranca <= '1';
            alarme <= '0';
        elsif rising_edge(clk) then
            case state is
                when desconfigurado =>
                    if config = '1' then
                        state <= configuracao;
                    end if;
                when configuracao =>
                    if valid = '1' then
                        senha <= entrada;
                        state <= operacao;
                        configurado <= '1';
                    end if;
                when operacao =>
                    if valid = '1' then
                        if senha = entrada then
                            tranca <= '0';
                        else
                            tentativas <= tentativas + 1;
                            if tentativas = 3 then
                                state <= erro;
                                alarme <= '1';
                            end if;
                        end if;
                    end if;
                when erro =>
                    if valid = '1' then
                        state <= desconfigurado;
                        alarme <= '0';
                        tentativas <= 0;
                    end if;
                when others =>
                    state <= desconfigurado;
            end case;
        end if;
    end process;
end behavior;

function compare_std_vector(a : std_logic_vector; b : std_logic_vector) return boolean is
    variable result : boolean := true;
begin
    for i in a'range loop
        if a(i) /= b(i) then
            result := false;
            exit;
        end if;
    end loop;
    return result;
end function;

