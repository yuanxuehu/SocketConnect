# Socket通信收发机制，包括StreamSocket/GCDAsyncSocket/SmartLink/ULink四种方式

## SocketConnect
### StreamSocket
//苹果原生API
// NSStream is an abstract class encapsulating the common API to NSInputStream and NSOutputStream.
// NSInputStream is an abstract class representing the base functionality of a read stream.
// NSOutputStream is an abstract class representing the base functionality of a write stream.

### GCDAsyncSocket
TCP

GCDAsyncSocket is a TCP/IP socket networking library built atop Grand Central Dispatch. Here are the key features available:

Native Objective-C, fully self-contained in one class.
No need to muck around with sockets or streams. This class handles everything for you.

Full delegate support
Errors, connections, read completions, write completions, progress, and disconnections all result in a call to your delegate method.

Queued non-blocking reads and writes, with optional timeouts.
You tell it what to read or write, and it handles everything for you. Queueing, buffering, and searching for termination sequences within the stream - all handled for you automatically.

Automatic socket acceptance.
Spin up a server socket, tell it to accept connections, and it will call you with new instances of itself for each connection.

Support for TCP streams over IPv4 and IPv6.
Automatically connect to IPv4 or IPv6 hosts. Automatically accept incoming connections over both IPv4 and IPv6 with a single instance of this class. No more worrying about multiple sockets.

Support for TLS / SSL
Secure your socket with ease using just a single method call. Available for both client and server sockets.

Fully GCD based and Thread-Safe
It runs entirely within its own GCD dispatch_queue, and is completely thread-safe. Further, the delegate methods are all invoked asynchronously onto a dispatch_queue of your choosing. This means parallel operation of your socket code, and your delegate/processing code.

### SmartLink
SmartLink 用于在物理网设备没有外部输入端时，使用手机对其进行配置的一种通用的说法。
SmartLink is used by NoInputNoOutput wireless devices to connect to AP. SmartLink is implemented on Linux mac80211 driver. For IoT devices it's more easy. The main technologies are as fowllows:

add monitor interface to main interface

### ULink
ULink 使用Wi-Fi 网络广播单向发送数据。接收者无需加入指定的Wi-Fi。
这种方式的数据传输，可以用来设置未联网的无线设备。

实现细节
Wi-Fi 传输过程中，MAC地址不会进行加密。其中组播报文的MAC地址是可以控制的（通过改变目的组播IP地址）。组播报文在二层网络中，会被广播发送。

数据的使用
7 bit 序列号 + 封装数据

传输数据的最大长度为254

序列号 7 bit （0 ~ 127）, 每个序列对应后面的两个字节。
序列号为0时，2个字节的复杂对应 数据长度 和 CRC校验。
