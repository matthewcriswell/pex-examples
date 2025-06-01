import subprocess, json

result = subprocess.run(['sudo', 'nft', '-j', 'list', 'ruleset'],
                        stdout=subprocess.PIPE, text=True, check=True)
ruleset = json.loads(result.stdout)
print(json.dumps(ruleset, indent=2))
