package il.co.codeguru.corewars8086.war;

import il.co.codeguru.corewars8086.ZombPoint;
import il.co.codeguru.corewars8086.memory.MemoryEventListener;
import il.co.codeguru.corewars8086.utils.EventMulticaster;

import java.io.IOException;


public class Competition {

	public static boolean endOnOneGroup; // $BOG
	public static ZombPoint[] zombPoints; //$BOG
	
    /** Maximum number of rounds in a single war. */
    public static int MAX_ROUND; // $BOG
    public static String SCORE_FILENAME= ""; // $BOG

    private CompetitionIterator competitionIterator;

    private EventMulticaster competitionEventCaster, memoryEventCaster;
    private CompetitionEventListener competitionEventListener;
    private MemoryEventListener memoryEventListener;

    private WarriorRepository warriorRepository;

    private War currentWar;

    private int warsPerCombination= 20;

    private int speed;
    public static final int MAXIMUM_SPEED = -1;
    private static final long DELAY_UNIT = 200;
    
    private long seed = 0;

    private boolean abort;

    public Competition() throws IOException {
        this(true);
    }

    public Competition(boolean shouldReadWarriorsFile) throws IOException {
        warriorRepository = new WarriorRepository(shouldReadWarriorsFile);

        competitionEventCaster = new EventMulticaster(CompetitionEventListener.class);
        competitionEventListener = (CompetitionEventListener) competitionEventCaster.getProxy();
        memoryEventCaster = new EventMulticaster(MemoryEventListener.class);
        memoryEventListener = (MemoryEventListener) memoryEventCaster.getProxy();
        speed = MAXIMUM_SPEED;
        abort = false;
    }

    public void runCompetition (int warsPerCombination, int warriorsPerGroup, boolean startPaused) throws Exception {
        this.warsPerCombination = warsPerCombination;
        competitionIterator = new CompetitionIterator(
            warriorRepository.getNumberOfGroups(), warriorsPerGroup);

        // run on every possible combination of warrior groups
        competitionEventListener.onCompetitionStart();
        for (int warCount = 0; warCount < getTotalNumberOfWars(); warCount++) {
            runWar(warriorRepository.createGroupList(competitionIterator.next()), startPaused);
            seed ++;
            if (abort) {
				break;
			}
        }
        competitionEventListener.onCompetitionEnd();
        warriorRepository.saveScoresToFile(SCORE_FILENAME);
        
        // $BOG
        if(zombPoints != null)
        	for(int i = 0;i < zombPoints.length;i++)
        		System.out.println("Address: 0x" + Integer.toHexString(zombPoints[i].getAddress()) + ", AverageScore: " + (zombPoints[i].getScore()/getTotalNumberOfWars()));
    }

    public int getTotalNumberOfWars() {
        return (int) competitionIterator.getNumberOfItems() * warsPerCombination;
    }

    public void runWar(WarriorGroup[] warriorGroups,boolean startPaused) throws Exception {
        currentWar = new War(memoryEventListener, competitionEventListener, startPaused);
        currentWar.setSeed(this.seed);
        competitionEventListener.onWarStart();
        currentWar.loadWarriorGroups(warriorGroups);

        boolean flag = false; // $BOG
        
        // go go go!
        int round = 0;
        while (round < MAX_ROUND) {
            competitionEventListener.onRound(round);

            competitionEventListener.onEndRound();

            // apply speed limits
            if (speed != MAXIMUM_SPEED) {
                // note: if speed is 1 (meaning game is paused), this will
                // always happen
                if (round % speed == 0) {
                    Thread.sleep(DELAY_UNIT);
                }

                if (speed == 1) { // paused
                    continue;
                }
            }

            //pause
            while (currentWar.isPaused()) Thread.sleep(DELAY_UNIT);

            //Single step run - stop next time
            if (currentWar.isSingleRound())
                currentWar.pause();

            if (currentWar.isOver()) {
                break;
            }
            
            // $BOG
            else if(endOnOneGroup && currentWar.getNumRemainingWarriors() == 2)
            {
            	if(areWarriorsTeam(currentWar.getWarriorsAliveNames()))
            	{
            		flag = true;
            		break;
            	}
            }

            currentWar.nextRound(round);

            ++round;
        }
        competitionEventListener.onRound(round);

        // $BOG
        if(zombPoints != null)
        	for(int i = 0;i < zombPoints.length;i++)
        		zombPoints[i].addScore(currentWar.getByteFromArena(zombPoints[i].getAddress()));
        
        int numAlive = currentWar.getNumRemainingWarriors();
        String names = currentWar.getRemainingWarriorNames();

        if (numAlive == 1) { // we have a single winner!
            competitionEventListener.onWarEnd(CompetitionEventListener.SINGLE_WINNER, names);
        } else if (flag || round == MAX_ROUND) { // maximum round reached
            competitionEventListener.onWarEnd(CompetitionEventListener.MAX_ROUND_REACHED, names);
        } else { // user abort
            competitionEventListener.onWarEnd(CompetitionEventListener.ABORTED, names);
        }
        currentWar.updateScores(warriorRepository);
        currentWar = null;
    }

    public int getCurrentWarrior() {
        if (currentWar != null) {
            return currentWar.getCurrentWarrior();
        } else {
            return -1;
        }
    }

    public void addCompetitionEventListener(CompetitionEventListener lis) {
        competitionEventCaster.add(lis);
    }
        public void removeCompetitionEventListener(CompetitionEventListener lis) {
    	competitionEventCaster.remove(lis);
    }
    
    public void addMemoryEventLister(MemoryEventListener lis) {
        memoryEventCaster.add(lis);
    }

    public void removeMemoryEventLister(MemoryEventListener lis) {
    	memoryEventCaster.remove(lis);
    }
    
    public WarriorRepository getWarriorRepository() {
        return warriorRepository;
    }

    /**
     * Set the speed of the competition, wither MAX_SPEED or a positive integer 
     * when 1 is the slowest speed
     * @param speed
     */
    public void setSpeed(int speed) {
        this.speed = speed;
    }

    public int getSpeed() {
        return speed;
    }

    public void setAbort(boolean abort) {
        this.abort = abort;
    }
    
    
    public War getCurrentWar(){
    	return currentWar;
    }
    
    public void setSeed(long seed){
    	this.seed = seed;
    }

    public long getSeed(){
        return seed;
    }
    
    /**
     *  $BOG
     */
    public boolean areWarriorsTeam(String[] names)
    {
    	return (names[0].substring(0, names[0].length()-1).equals(names[1].substring(0, names[1].length()-1)));
    }
    
}