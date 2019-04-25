#!/usr/bin/python
from flask import Flask, request, redirect, render_template
from flask_mysqldb import MySQL
app = Flask(__name__)

## Configure DB
app.config['MYSQL_HOST'] = '10.0.2.3'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'root123'
app.config['MYSQL_DB'] = 'flaskapp'
app.config['MYSQL_PORT'] = 32060

mysql = MySQL(app)

@app.route('/')
def index():
        return render_template('methods.html')


@app.route('/update', methods=['GET', 'POST'])
def update():
        if request.method == 'POST':
                userDetails = request.form
                serial = userDetails['serial']
                name = userDetails['name']
                email = userDetails['email']
                cur = mysql.connection.cursor()
                cur.execute("INSERT INTO users(serial,name, email) VALUES(%s,%s, %s)",(int(serial),name, email))
                mysql.connection.commit()
                cur.close()
#               return 'SUCCESS'
                return redirect('/users')
        return render_template('index.html')

@app.route('/users')
def users():
        cur = mysql.connection.cursor()
        resultValue = cur.execute("SELECT * from users")
        if resultValue > 0:
                userDetails = cur.fetchall()
                return render_template('users.html', userDetails=userDetails)

@app.route('/Authenticate', methods=['GET','POST'])
def Authenticate():
        if request.method == 'POST':
                userDetails = request.form
                serial = userDetails['serial']
                name = userDetails['name']
                cursor = mysql.connection.cursor()
                cursor.execute("SELECT * from users where serial ='" + serial + "' and name ='" + name + "'")
                data = cursor.fetchone()
                if data is None:
                        return index()
                else:
                        return "Logged in successfully"
        return render_template('index1.html')


if __name__ == '__main__':
        app.run(debug=True,host='0.0.0.0',port='5000')
