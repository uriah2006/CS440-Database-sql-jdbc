package hw10in;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public abstract class second {

	protected Connection conn;

	public second() {
		super();
	}

	public void run() throws SQLException, ClassNotFoundException {
		setConnection();
	}

	protected void setConnection() throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.OracleDriver");
		// DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
		conn = DriverManager.getConnection(
				"jdbc:oracle:thin:@cs440.systems.wvu.edu:2222:cs440",
				"usypolt", "*******");
	}

}