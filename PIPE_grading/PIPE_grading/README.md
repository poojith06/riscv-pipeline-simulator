This folder contains the testcases and the script to grade the submissions for the pipelined processor. The testcases are located in the `testcases/Pipelined` directory, and the results will be saved in `results.csv` and `error.txt` will contain any errors.

To run the script, follow these steps:
1. Place your .zip file containing the Verilog code for the pipelined processor in the `root/submission` directory. Make sure to name this zip file as `Team_xx.zip` else you might face errors.
2. Make sure your pipelined testbench is named either of the ones used in the header of the script.
3. Run the script using the command: `python3 script.py` from the `PIPE_grading` directory.
4. Testcase-wise results and the total will be saved in `results.csv` and any errors will be logged in `error.txt`.
5. If you have not followed the submission guidelines, you may face errors, which you have to debug yourself. Such submissions attract a **20% penalty** on the total marks. 
6. Note that the final marks on moodle accounts for the **20% penalty** as well. 

The following are the marks distribution for the pipelined processor:
- Testcases 00:24 = 1 mark each
- Testcase  25 = 3 marks
- Testcases 26:39 = 1 mark each
- Testcases 40:45 = 3 marks each
- Testcase  46 = 1 mark each