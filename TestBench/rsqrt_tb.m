clear;
clc;
%function rsqrt_tb
%Author: Kyler Callahan
      
%------------------------------------------------------------
% Note: it appears that the cosimWizard needs to be re-run if
% this is moved to a different machine (VHDL needs to be
% recompile in ModelSim).
%------------------------------------------------------------

% HdlCosimulation System Object creation (this Matlab function was created
% by the cosimWizard).
rsqrt_hdl = hdlcosim_rsqrt;            

% Simulate for Nclock rising edges (this will be the length of the
% simulation)
Nclock_edges = 100;  % Total number of numbers tested
clk_num_delay = 20; % Number of clock cyles spent on a single input
clk_total = 1;      % Keeps track of output history

for clki=1:Nclock_edges
    %-----------------------------------------------------------------
    % Create our input vector at each clock edge, which must be a 
    % fixed-point data type.  The word width of the fixed point data type
    % must match the width of the std_logic_vector input.
    %-----------------------------------------------------------------
    fixed_word_width     = 32;  % width of input to component
    fixed_point_value    = randi([1 2^16-1],1,1) + rand; % choose a random integer between [0 2^W-1] - Note: can't have a zero input....
    fixed_point_signed   = 0;  % unsiged = 0, signed = 1;
    fixed_point_fraction = 16;  % fraction width (location of binary point within word)
    input_vector1 = fi(fixed_point_value, fixed_point_signed, fixed_word_width, fixed_point_fraction); % make the input a fixed point data type
    input_history{clki} = input_vector1;  % capture the inputs 
    
    %-----------------------------------------------------------------
    % Push the input(s) into the component using the step function on the
    % system object lzc_hdl
    % If there are multiple I/O, use
    % [out1, out2, out3] = step(lzc_hdl, in1, in2, in3);
    % and understand all I/O data types are fixed-point objects
    % where the inputs can be created by the fi() function.
    %-----------------------------------------------------------------
    
    %hold the same input for 20 clock cycles
    for clk_extend = 1: clk_num_delay
    output_vector1 = step(rsqrt_hdl,input_vector1);
    
    output_vector1 = fi(output_vector1, fixed_point_signed, fixed_word_width, fixed_point_fraction);
    %-----------------------------------------------------------------
    % Save the outputs (which are fixed-point objects)
    %-----------------------------------------------------------------
    output_history{clk_total} = output_vector1;  % capture the output
    clk_total = clk_total + 1;
    
    end
    
end

%-----------------------------------------------------------------
% Perform the desired comparison (with the latency between input
% and output appropriately corrected).
%-----------------------------------------------------------------
latency     = 19;  % latency in clock cycles through the component
error_index = 1;
error_case  = [];
for clki=1:Nclock_edges
    in1  = input_history{clki};  
    out1 = output_history{clki*latency};  % get the output associated with current output
    %------------------------------------------------------
    % Perfom the comparison with the "true" output 
    %------------------------------------------------------
    decIn = double(in1);
    
    calcout = 1/sqrt(decIn);
    decOut = double(out1);
    abs_diff = abs(calcout - decOut);
    
    diff_history(clki) = abs_diff;
    
    

end

% Stats about the differences
min_diff = min(diff_history)
max_diff = max(diff_history)
mean_diff = mean(diff_history)
