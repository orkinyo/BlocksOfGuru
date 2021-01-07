package il.co.codeguru.corewars8086;

public class ZombPoint
{
	private short address;
	private float score;
	
	
	public ZombPoint(short address, int score)
	{
		this.address = address;
		this.score = score;
	}
	
	
	public void setScore(int score)
	{
		this.score = score;
	}
	
	
	public void addScore(int score)
	{
		this.score += score;
	}
	
	
	public float getScore()
	{
		return this.score;
	}
	
	
	public short getAddress()
	{
		return this.address;
	}
}
