import pyodbc
import streamlit as st
import pandas as pd

print("hello")

SERVER = 'localhost'
DATABASE = 'sportsleaguemgmtsys'
USERNAME = 'sa'
PASSWORD = 'Damg6210*'
connectionString = f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};UID={USERNAME};PWD={PASSWORD};TrustServerCertificate=yes;'

conn = pyodbc.connect(connectionString)
print(conn)
st.title('Sports League Management System')


SQL_QUERY = """
SELECT userID, userEmail, firstName, lastName from [user]
"""

cursor = conn.cursor()
cursor.execute(SQL_QUERY)
results = cursor.fetchall()

records = pd.DataFrame.from_records(results, columns=['userID', 'userEmail', 'firstName', 'lastName'])

print(records)
st.write("Current Users Data:")
st.write(records[['userID','userEmail','firstName','lastName']])

st.header("Add a new User")

userEmail = st.text_input("User Email:")
firstName = st.text_input("First Name:")
lastName = st.text_input("Last Name:")
password = st.text_input("Password:",type='password')
streetName = st.text_input("Street Name:")
state = st.text_input("State:")
country = st.text_input("Country:")
postalCode = st.text_input("Postal Code:")
userType = st.selectbox("User Type", ["Viewer", "TeamStaff", "Admin"])
success = False
if st.button("Add User"):
        # Perform database insert operation here
        # You will need to write the logic to insert data into your database
    cursor = conn.cursor()
    cursor.execute("OPEN SYMMETRIC KEY userPass_SM DECRYPTION BY CERTIFICATE userPass;")
    encrypted_password = "ENCRYPTBYKEY(Key_GUID('userPass_SM'), CONVERT(VARBINARY, '{}'))".format(password)
    sql_query = f"""
        INSERT INTO [user] (userEmail, firstName, lastName, [password], streetName, [state], country, postalCode, userType)
        VALUES ('{userEmail}', '{firstName}', '{lastName}', {encrypted_password}, '{streetName}', '{state}', '{country}', '{postalCode}', '{userType}')
    """
    cursor.execute(sql_query)
    conn.commit()
    st.success("User added successfully!")
    success = True

if(success):
    st.title('Enter Admin Information')
admin_role = st.text_input("Admin Role:")
admin_permissions = st.text_input("Admin Permissions:")
joining_date = st.date_input("Joining Date:")
if st.button("Submit Admin Information"):
        # Perform database insert operation for admin information
        cursor = conn.cursor()
        sql_query_admin = f""" 
            EXEC insertToAdminTable @adminRole='{admin_role}', @adminPermissions='{admin_permissions}', @joiningDate='{joining_date}' 
            """
        cursor.execute(sql_query_admin)
        conn.commit()
        st.success("Admin added successfully!")
