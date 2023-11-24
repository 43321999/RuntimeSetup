# setup
## server
### ~/apps/overlay-storage/Dockerfile
```dockerfile
FROM node:lts-bookworm
RUN apt update
COPY exports /etc/exports
COPY main.js /
EXPOSE 111/udp 111/tcp 2049/udp 2049/tcp
CMD ["node", "/main.js";]
```
### ~/apps/overlay-storage/main.js
```javascript
import { spawn } from 'child_process';

# Паттерн «Цепочка обязанностей» (Chain of Responsibility)
class NFSStorage {
  constructor() {
    this.nfsPackageName = 'nfs-kernel-server';
    this.nfsServiceName = 'nfs-kernel-server';
  }

  async install() {
    try {
      await this.executeCommand('apt-get', ['install', this.nfsPackageName, '-y']);
      console.log(`Установка ${this.nfsPackageName} выполнена успешно`);
    } catch (error) {
      console.error(`Возникла ошибка при установке ${this.nfsPackageName}`);
    }
  }

  async start() {
    try {
      await this.executeCommand('systemctl', ['start', this.nfsServiceName]);
      console.log(`${this.nfsServiceName} успешно запущен`);
    } catch (error) {
      console.error(`Возникла ошибка при запуске ${this.nfsServiceName}`);
    }
  }

  executeCommand(command, args) {
    return new Promise((resolve, reject) => {
      const process = spawn(command, args);
      process.on('exit', (code) => {
        if (code === 0) {
          resolve();
        } else {
          reject(new Error(`Exit code: ${code}`));
        }
      });
    });
  }
}
const nfsStorage = new NFSStorage();
nfsStorage.install().then(() => {
  nfsStorage.start();
});
```
### ~/apps/overlay-storage/exports
```
/srv/nfs_share *(rw,sync,no_subtree_check)
```
## client
### lvm