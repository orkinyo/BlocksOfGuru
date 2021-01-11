package il.co.codeguru.corewars8086;

import il.co.codeguru.corewars8086.cpu.Cpu;
import il.co.codeguru.corewars8086.gui.CompetitionWindow;
import il.co.codeguru.corewars8086.war.Competition;
import il.co.codeguru.corewars8086.war.War;
import il.co.codeguru.corewars8086.war.WarriorRepository;

import java.io.IOException;


public class BlockOfGuruEngine
{
	static String help = "\t--gui\t\t\ton/off - turn on or off competition window (on by default)\n"
			+ "\t--int86\t\t\ton/off - turn on or off int 0x86 (on by default)\n"
			+ "\t--int87\t\t\ton/off - turn on or off int 0x87 (off by default)\n"
			+ "\t--max\t\t\tMAX_ROUND - set max number of rounds per war (200,000 by default)\n"
			+ "\t--wars\t\t\tWARS_PER_COMBINATION - set amount of wars to run per survivors' combination\n\t\t\t\t(1,000 by default)\n"
			+ "\t--seed\t\t\tSEED - set the initial randomization seed (guru by default)\n"
			+ "\t--end\t\t\ton/off - turn on or off the option to end a war with one team left (on by default)\n"
			+ "\t--output, -o\t\tFILEPATH - set the scores output file path, .csv extension is added by default,\n\t\t\t\t/ or \\ can be used in the file path (scores by default) **if the output file path\n\t\t\t\tis stdout, the output of the program will not be saved to a file, but be printed\n\t\t\t\tto stdout. if you would like to only print the score of one team, use stdout:GROUP_NAME\n"
			+ "\t--delete-files\t\ton/off - turn on or off the deletion of warrior and zombie files after reading\n"
			+ "\t--zombs\t\t\ton/off - turn on or off zombs mode. in zombs mode, each survivor gets a point for\n\t\t\t\tmaking a zomb die in its territory (initial load address), marking a successful takeover\n\t\t\t\t(default off)\n"
			+ "\t--debug-zombs\t\ton/off - turn on or off the printing of the survivor's names' that got a point\n\t\t\t\tfrom zombs mode\n"
			+ "\t--version, -v\t\tdisplay version\n"
			+ "\t--help, -h\t\tdisplay this help and exit";
	
	static String credits = "Made by BlocksOfGuru members:\nAlon Dayan\nTom Shani";
	
	static String version = "1.5";
	
	public static void main (String args[]) throws IOException
	{
		if(args.length > 0 && (args[0].equals("--help") || args[0].equals("-h")))
		{
			System.out.println(help);
			return;
		}
		
		if(args.length > 0 && (args[0].equals("--version") || args[0].equals("-v")))
		{
			System.out.println("Version " + version);
			return;
		}
			
		if(args.length > 1 && args[0].equals("--fuck") && args[1].equals("--globi"))
		{
			System.out.println(credits);
			return;
		}
		
		if(args.length%2 != 0)
		{
			System.out.println("Invalid number of arguments");
			return;
		}
		
		boolean isGui = true; // $BOG
		boolean isInt86 = true; // $BOG
		boolean isInt87 = false; // $BOG
		int maxRound = 200000; // $BOG
		String warsPerComb = "1000"; // $BOG
		String seed = "guru"; // $BOG
		boolean endOnOneGroup = true; // $BOG
		String filePath = "scores.csv"; // $BOG
		boolean outputStdout = false; // $BOG
		String outputGroup = ""; // $BOG
		boolean deleteFilesAfterReading = false; // $BOG
		boolean endWhenZombsDead = false; // $BOG
		boolean debugZombs = false; // $BOG
		
		for(int i = 0;i < args.length;i+=2)
		{
			if(args[i].equals("--gui"))
				isGui = args[i+1].equals("on");
			
			else if(args[i].equals("--int86"))
				isInt86 = args[i+1].equals("on");
			
			else if(args[i].equals("--int87"))
				isInt87 = args[i+1].equals("on");
			
			else if(args[i].equals("--max"))
				maxRound = Integer.parseInt(args[i+1]);
			
			else if(args[i].equals("--wars"))
				warsPerComb = args[i+1];
			
			else if(args[i].equals("--seed"))
				seed = args[i+1];
			
			else if(args[i].equals("--end"))
				endOnOneGroup = args[i+1].equals("on");
			
			else if(args[i].equals("--output") || args[i].equals("-o"))
			{
				outputStdout = args[i+1].substring(0, "stdout".length()).equals("stdout");
				
				if(args[i+1].length() > "stdout".length())
					outputGroup = args[i+1].substring("stdout".length() + 1);
				
				filePath = args[i+1] + ".csv";
			}
			
			else if(args[i].equals("--delete-files"))
				deleteFilesAfterReading = args[i+1].equals("on");
			
			else if(args[i].equals("--zombs"))
				endWhenZombsDead = args[i+1].equals("on");
			
			else if(args[i].equals("--debug-zombs"))
				debugZombs = args[i+1].equals("on");
			
			else
			{	
				System.out.println(args[i] + " is an invalid option");
				System.out.println("try --help for more information");
				return;
			}
			
		}
		
        Cpu.isInt86 = isInt86;
        Cpu.isInt87 = isInt87;
        Competition.MAX_ROUND = maxRound;
        Competition.endOnOneGroup = endOnOneGroup;
		Competition.SCORE_FILENAME = filePath;
		Competition.endWhenZombsDead = endWhenZombsDead;
        WarriorRepository.outputStdout = outputStdout;
        WarriorRepository.deleteFilesAfterReading = deleteFilesAfterReading;
		WarriorRepository.outputGroup = outputGroup;
        War.debugZombs = debugZombs;
		
		
        if(isGui)
        {
            CompetitionWindow.warsPerComb = warsPerComb;
            CompetitionWindow.seedString = seed;
        	CompetitionWindow c = new CompetitionWindow();
        	c.setVisible(true);
        	c.pack();
        }
        
        else
        	runWar(seed, Integer.parseInt(warsPerComb));
    }


	public static void runWar(String seed, int wars) throws IOException
	{
		Competition competition = new Competition();
		String SEED_PREFIX = "SEED!@#=";
        
		try {
            long seedValue;
            if (seed.startsWith(SEED_PREFIX)){
                seedValue = Long.parseLong(seed.substring(SEED_PREFIX.length()));
            }
            else {
                seedValue = seed.hashCode();
            }
            
            competition.setSeed(seedValue);
            final int battlesPerGroup = wars;
            final int warriorsPerGroup = Math.min(4, competition.getWarriorRepository().getNumberOfGroups());
            
            Thread warThread = new Thread("CompetitionThread") {
                @Override
                public void run() {
                    try {
                        competition.runCompetition(battlesPerGroup, warriorsPerGroup, false);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                };
            };
            
            warThread.start();
            
        } catch (NumberFormatException e2) {
            System.out.println(e2);
        }
    }
}