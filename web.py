from flask import *
import paramiko
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
app = Flask(__name__)

@app.route('/default')
def default():
    return redirect(url_for('home'))

@app.route('/')
def home():
    return render_template('home.html')
  
@app.route('/login',methods = ['POST'])
def login():
    hostname=request.form['hostname']
    username=request.form['sidadm']
    password=request.form['pass']
    try:
        client.connect(hostname=hostname, username=username, password=password)
        try:
            output='<html><head><style> th, td {  border: 1px solid black;}</style><title>Paramters</title></head><body>'
            sftp_client = client.open_sftp()

            remote_file = sftp_client.open('/orascripts/Hardening/output.txt')
            cond=0
            for line in remote_file:

                if line.split()[0] == "Profile" or line.split()[0] == "Hana" or \
                        line.split()[0] == "Oracle" or line.split()[0] == "Hostagent" :
                    output+="<h2>"+line+"</h2><table>\n"
                    continue
                if line.split()[0] == "END":
                    cond+=1

                    if cond > 0:
                        output +="</table>"
                        continue

                output+="<tr>\n"
                for elem in line.split("^"):
                    output+="<th>"+elem+"</th>\n"
                output+="</tr>\n"

            output+="</table></body></html>"
            #print(output)
            return output
        finally:
            remote_file.close()
    except:
        print("[!] Cannot connect to the SSH Server")
        return "Failed"
          #return redirect(url_for('default'))
        exit()
if __name__ == '__main__':
   app.run(debug = True) 
