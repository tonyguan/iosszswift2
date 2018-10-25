<?php

	$deviceToken= '9965e2454864168c3c897f27bd800cd507f0858c2ebb1f52526fc97adf9556e9';
	//推送方式，包含内容和声音
	$body = array("aps" => array("alert" => '新年好. from PHP', "category" => 'custom_category_id', "badge" => 11,"sound"=>'default'));  
	//创建数据流上下文对象
	$ctx = stream_context_create();
	//设置pem格式文件
	$pem = "apns-dev.pem";
	//设置数据流上下的本地认证证书
	stream_context_set_option($ctx,"ssl","local_cert", $pem);
	$pass = "51work6.com";
	//设置数据流上下的密码
	stream_context_set_option($ctx, 'ssl', 'passphrase', $pass);
	//产品发布APNS服务器，gateway.push.apple.com
	//测试APNS服务器，gateway.sandbox.push.apple.com
	//socket通讯
	$fp = stream_socket_client("ssl://gateway.sandbox.push.apple.com:2195", $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);
	if (!$fp) {
		echo "连接失败.";
		return;
	}
	print "连接OK\n";
	//载荷信息，JSON编码
	$payload = json_encode($body);
	//构建发送的二进制信息
	$msg = chr(0) . pack("n",32) . pack("H*", str_replace(' ', '', $deviceToken)) . pack("n",strlen($payload)) . $payload;
	echo "发送消息:" . $payload ."\n";
	fwrite($fp, $msg);
	fclose($fp);
	
?>