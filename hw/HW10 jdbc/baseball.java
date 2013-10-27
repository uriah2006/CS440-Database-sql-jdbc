package hw10in;

import java.sql.SQLException;

import oracle.jdbc.driver.OracleConnection;
import oracle.sql.CustomDatum;
import oracle.sql.Datum;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;

public class baseball implements CustomDatum {

	private String name;
	private int year;
	private int age;
	private String battingPreference;
	private double battingAverage;

	public baseball(String n, int y, int a, String bP, double bA) {
		this.name = n;
		this.year = y;
		this.age = a;
		this.battingPreference = bP;
		this.battingAverage = bA;
	}

	public String toString() {
		return String.format("%s,%d,%d,%s,%f", name, year, age,
				battingPreference, battingAverage);
	}

	public Object[] getObjArray() {
		return new Object[] { name, year, age, battingPreference,
				battingAverage };
	}

	public Datum toDatum(OracleConnection arg0) throws SQLException {
		StructDescriptor descriptor = new StructDescriptor("SCOTT.WORKER_TY_2",
				arg0);
		return new STRUCT(descriptor, arg0, getObjArray());
	}

	public CustomDatum create(Datum arg0, int arg1) throws SQLException {
		Object[] attributes = ((STRUCT) arg0).getAttributes();
		return new baseball((String) attributes[0], (Integer) attributes[1],
				(Integer) attributes[2], (String) attributes[3],
				(Double) attributes[4]);
	}
}