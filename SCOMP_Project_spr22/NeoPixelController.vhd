-- L07-4 NeoPixel Controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity NeoPixelController is

	port(
		clk_10M   : in   std_logic;
		resetn    : in   std_logic;
		io_write  : in   std_logic ;
		cs_addr   : in   std_logic ;
		cs_data   : in   std_logic ;
		bit_24_GB : in   std_logic; 
		bit_24_R  : in   std_logic;
		cs_all	 : in   std_logic;
		pxl_tog	 : in	  std_logic;
		data_in   : in   std_logic_vector(15 downto 0);
		data_word : out  std_logic_vector(15 downto 0);
		sda       : out  std_logic
	); 

end entity;

architecture internals of NeoPixelController is
	
	-- Signals for the RAM read and write addresses
	signal ram_read_addr, ram_write_addr : std_logic_vector(7 downto 0);
	
	-- RAM write enable
	signal ram_we : std_logic;
	
	--Holds the auto-increment direction
	signal IncrementDirection : std_logic;

	-- Signals for data coming out of memory
	signal ram_read_data: std_logic_vector(23 downto 0);
	
	-- Holds data from A port in memory for user read function
	signal ram_read: std_logic_vector(23 downto 0); 
	
	-- Signal to store the current output pixel's color data
	signal pixel_buffer : std_logic_vector(23 downto 0);
	
	--Holds the color to be set to all pixels
	signal data_set_all : std_logic_vector(23 downto 0);
	
	
	signal TempColorHolder : std_logic_vector(23 downto 0);

	-- Signal SCOMP will write to before it gets stored into memory
	signal ram_write_buffer : std_logic_vector(23 downto 0);

	-- RAM interface state machine signals
	type write_states is (idle, setAll, storing, reading);
	signal wstate: write_states;

	
begin

	-- This is the RAM that will store the pixel data.
	-- It is dual-ported.  SCOMP will access port "A",
	-- and the NeoPixel controller will access port "B".
	pixelRAM : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		indata_reg_b => "CLOCK0",
		init_file => "pixeldata.mif",
		intended_device_family => "Cyclone V",
		lpm_type => "altsyncram",
		numwords_a => 256,
		numwords_b => 256,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
		widthad_a => 8,
		widthad_b => 8,
		width_a => 24,
		width_b => 24,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	PORT MAP (
		address_a => ram_write_addr,
		address_b => ram_read_addr,
		clock0 => clk_10M,
		data_a => ram_write_buffer,
		data_b => x"000000",
		wren_a => ram_we,
		wren_b => '0',
		q_a => ram_read,
		q_b => ram_read_data
	);
	
	-- Set the data to the io-data bus when the user is trying to read data
	data_word <= (ram_read(23 downto 18) & ram_read(15 downto 11) & ram_read(7 downto 3)) when ((cs_data='1') and (io_write='0')) else "ZZZZZZZZZZZZZZZZ";

	
	
	-- This process implements the NeoPixel protocol by
	-- using several counters to keep track of clock cycles,
	-- which pixel is being written to, and which bit within
	-- that data is being written.
	process (clk_10M, resetn)
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8; -- high time for '1'
		constant t0h : integer := 3; -- high time for '0'
		constant ttot : integer := 12; -- total bit time
		
		constant npix : integer := 256;

		-- which bit in the 24 bits is being sent
		variable bit_count   : integer range 0 to 31;
		-- counter to count through the bit encoding
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 1000;
		-- Counter for the current pixel
		variable pixel_count : integer range 0 to 255;
		
		
	begin
		
		if resetn = '0' then
			-- reset all counters
			bit_count := 23;
			enc_count := 0;
			reset_count := 1000;
			-- set sda inactive
			sda <= '0';

		elsif (rising_edge(clk_10M)) then

			-- This IF block controls the various counters
			if reset_count /= 0 then -- in reset/end-of-frame period
				-- during reset period, ensure other counters are reset
				pixel_count := 0;
				bit_count := 23;
				enc_count := 0;
				-- decrement the reset count
				reset_count := reset_count - 1;
				-- load data from memory
				pixel_buffer <= ram_read_data;
			
				
			else -- not in reset period (i.e. currently sending data)
				-- handle reaching end of a bit
				if enc_count = (ttot-1) then -- is end of this bit?
					enc_count := 0;
					-- shift to next bit
					pixel_buffer <= pixel_buffer(22 downto 0) & '0';
					if bit_count = 0 then -- is end of this pixels's data?
						bit_count := 23; -- start a new pixel
						pixel_buffer <= ram_read_data;
						
						if pixel_count = npix-1 then -- is end of all pixels?
							-- begin the reset period
							reset_count := 1000;
							
						else
							pixel_count := pixel_count + 1;
						end if;
					else
						-- if not end of this pixel's data, decrement count
						bit_count := bit_count - 1;
					end if;
				else
					-- within a bit, count to achieve correct pulse widths
					enc_count := enc_count + 1;
				end if;
			end if;
			
			
			-- This IF block controls the RAM read address to step through pixels
			if reset_count /= 0 then
				ram_read_addr <= x"00";
				
			
				
			elsif (bit_count = 1) AND (enc_count = 0) then
				-- increment the RAM address as each pixel ends
				
				ram_read_addr <= ram_read_addr + 1;

				
			end if;
			
			
			-- This IF block controls sda
			if reset_count > 0 then
				-- sda is 0 during reset/latch
				sda <= '0';
			elsif 
				-- sda is 1 in the first part of a bit.
				-- Length of first part depends on if bit is 1 or 0
				( (pixel_buffer(23) = '1') and (enc_count < t1h) )
				or
				( (pixel_buffer(23) = '0') and (enc_count < t0h) )
				then sda <= '1';
			else
				sda <= '0';
			end if;
			
		end if;
	end process;
	
	
	
process(clk_10M, resetn, cs_addr)
	begin

	
		-- The sequnce of events needed to store data into memory will be
		-- implemented with a state machine.
		-- Although there are ways to more simply connect SCOMP's I/O system
		-- to an altsyncram module, it would only work with under specific 
		-- circumstances, and would be limited to just simple writes.  Since
		-- you will probably want to do more complicated things, this is an
		-- example of something that could be extended to do more complicated
		-- things.
		-- Note that 'ram_we' is *not* implemented as a Moore output of this state
		-- machine, because Moore outputs are susceptible to glitches, and
		-- that's a bad thing for memory control signals.
		
		
		--Reset Signals to a default
		if resetn = '0' then
			wstate <= idle;
			ram_we <= '0';
			ram_write_buffer <= x"000000";
			ram_write_addr <= x"00";
			IncrementDirection <= '0';
			TempColorHolder <= "000000000000000000000000";
			-- Note that resetting this device does NOT clear the memory.
			-- Clearing memory would require cycling through each address
			-- and setting them all to 0.
		elsif rising_edge(clk_10M) then
			case wstate is
			-- Default State
			when idle =>
			
				
				if (io_write = '1') and (cs_data='1') then
					-- latch the current data into the temporary storage register,
					-- because this is the only time it'll be available.
					-- Convert RGB565 to 24-bit color
					ram_write_buffer <= data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0) & "000";
					-- can raise ram_we on the upcoming transition, because data
					-- won't be stored until next clock cycle.
					ram_we <= '1';
					-- Change state
					wstate <= storing;
				
				
				
				elsif (io_write = '1') and (bit_24_R = '1') then
					-- Set upper 8 bits of the 24 bit color. Does not update the pixel
					TempColorHolder <= ((TempColorHolder and "111111110000000011111111") or ("00000000" & data_in(7 downto 0) & "00000000"));
					
				elsif (io_write = '1') and (bit_24_GB = '1') then
					-- Add the datainput to the lower 16 bits of the TempColorHolder and update the pixel with 
					-- The current Temp Color Holder
					
					-- Users should set the green component of the pixel first
					TempColorHolder <= ((TempColorHolder and "000000001111111100000000") or (data_in(15 downto 8) & "00000000" & data_in(7 downto 0)));
					ram_write_buffer <= TempColorHolder;
					ram_we <= '1'; -- write
					wstate <= storing; -- store and auto inc.
				
				
				-- When reading, auto increment (going to storing to reuse the auto increment code thats in storing)
				elsif (io_write = '0') and (cs_data='1') then
					wstate <= storing;
					
				
				
				elsif (io_write = '1') and (cs_all='1') then
					-- store data_in into a signal to hold its value
					data_set_all    <= data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0) & "000";
					-- Address = 0
					ram_write_addr <= ram_write_addr - ram_write_addr;
					-- Set the first pixel to the new color.
					ram_write_buffer <= data_set_all;
					ram_we <= '1';
					wstate <= setAll; -- goto set all state

				
				-- set address using data_in
				elsif (io_write = '1') and (cs_addr='1') then
					ram_write_addr <= data_in(7 downto 0);
					
				-- Toggle autoincrement direction
				elsif (io_write = '1') and (pxl_tog='1') then
				
					if(IncrementDirection = '0') then
						IncrementDirection <= '1';
					else
						IncrementDirection <= '0';
					end if;
					
				
				end if;
				
				
			
			when setAll  =>
				-- if after last pixel
				if(ram_write_addr = 256) then 
					ram_we <= '0';
					-- reset to address 0 and return to idle
					wstate <= idle;
					ram_write_addr <= ram_write_addr - ram_write_addr;
					
					
					
				-- The Following if statements are similar to in statements in idle.
				-- They are designed to handle what happens if the user interacts with
				-- the peripheral when the set-all loop is still running
				
				-- If a situation doesn't need storing then it goes back to idle
				-- Any data writing defaults to writing to pixel zero for consistancy
				-- since the end of the set-all loop also sets the address to zero
				
				-- if 16 bit data is written 
				elsif (io_write = '1') and (cs_data='1') then
					wstate <= storing;
					ram_write_addr <= ram_write_addr - ram_write_addr;
					ram_write_buffer  <= data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0) & "000";
				
				-- If an address is set
				elsif (io_write = '1') and (cs_addr='1') then
					wstate <= idle;
					ram_we <= '0';
					ram_write_addr <= data_in(7 downto 0);
					
				-- if data is read
				elsif (io_write = '0') and (cs_data='1') then
					wstate <= storing;
					ram_write_addr <= ram_write_addr - ram_write_addr;
				
				-- If lower 16 bits of a 24 bit color are written
				elsif (io_write = '1') and (bit_24_GB = '1') then
					wstate <= storing;
					ram_write_addr <= ram_write_addr - ram_write_addr;
					
					TempColorHolder <= ((TempColorHolder and "111111110000000011111111") or ("00000000" & data_in(7 downto 0) & "00000000"));
					ram_write_buffer <= TempColorHolder;
					
				-- If upper 8 bits of a 24 bit color are written
				elsif (io_write = '1') and (bit_24_R = '1') then
					TempColorHolder <= ((TempColorHolder and "000000001111111111111111") or (data_in(7 downto 0) & "0000000000000000"));
					ram_we <= '0';
					ram_write_addr <= ram_write_addr - ram_write_addr;
					wstate <= idle;
					
				-- if increment direction is switched. Does not break out of the set all loop.
				elsif (io_write = '1') and (pxl_tog='1') then
				
					if(IncrementDirection = '0') then
						IncrementDirection <= '1';
					else
						IncrementDirection <= '0';
					end if;
					
				-- if the peripheral isn't interacted with and this isn't the last pixel
				else
					-- goto next pixel and set data.
					ram_write_addr <= ram_write_addr + 1;
					ram_write_buffer <= data_set_all;
					
				end if;
				
				
				
			when storing =>
				-- lowers ram_we and handles auto incrementing
				if IncrementDirection = '0' then
				if ram_write_addr /= 255 then 
						ram_write_addr <= ram_write_addr + 1;
					end if;
				elsif IncrementDirection = '1' then
					if ram_write_addr /= 0 then 
						ram_write_addr <= ram_write_addr - 1;
					end if;
				end if;
				
				
				ram_we <= '0';
				wstate <= idle;
				
			when others =>
				wstate <= idle;
			end case;
		end if;
	end process;

	
	
end internals;

