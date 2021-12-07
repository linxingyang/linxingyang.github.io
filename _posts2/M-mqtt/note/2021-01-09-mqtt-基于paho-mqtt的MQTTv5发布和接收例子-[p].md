---
layout: post
permalink: /:year/bc5a8c01c1664643be595e8c82mqtteg/index
title: 2021-01-09-mqtt-基于paho-mqtt的MQTTv5发布和接收例子
categories: [mqtt]
tags: [c,c++,mqtt,mosquitto,mosquitto系列]
relative-tags: [mosquitto系列]
excerpt: paho-mqtt,MQTTv5,发布,接收,例子
description: 基于paho-mqtt的MQTTv5发布和接收例子
catalog: false
---



基于paho-mqttV5的发送和接收例子



```c++
#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Windows.h>
#include <string>
using namespace std;
#include "paho-mqtt/MQTTClient.h"
#define ADDRESS     "tcp://127.0.0.1:1883"
#define CLIENTID    "ExampleClientPub"
#define TOPIC       "test/test"
#define PAYLOAD     "Hello World!"
#define USERNAME    "linxy"
#define PASSWORD    "123456"
#define QOS         1
#define TIMEOUT     10000L

#define PUBLISH_MODE 1

/** 
 * @details just simple example, DO NOT use in product environment
 */
int _tmain(int argc, _TCHAR* argv[])
{
	int rc = 0;
	MQTTClient client;
	
	/* create */
	MQTTClient_createOptions options = MQTTClient_createOptions_initializer;
	options.MQTTVersion = MQTTVERSION_5;
	if (MQTTCLIENT_SUCCESS != (rc = MQTTClient_createWithOptions(&client,  
		ADDRESS, CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL, &options))) 
	{
		printf("create fail\n");
		getchar();
	}
	
	/* basic conn opts */
	MQTTClient_connectOptions conn_opts = MQTTClient_connectOptions_initializer5;
	conn_opts.keepAliveInterval = 20;
	conn_opts.cleanstart = 1;
	conn_opts.username = USERNAME;
	conn_opts.password = PASSWORD;
	/* set properties */
	MQTTProperties connPros = MQTTProperties_initializer;
	MQTTProperty maximumPackageSize = { MQTTPROPERTY_CODE_MAXIMUM_PACKET_SIZE, 65535 };
	MQTTProperty topicAliasMaximum = { MQTTPROPERTY_CODE_TOPIC_ALIAS_MAXIMUM, 4096 };
	MQTTProperties_add(&connPros, &maximumPackageSize);
	MQTTProperties_add(&connPros, &topicAliasMaximum);
	/* connect */
	MQTTResponse connRsp = MQTTClient_connect5(client, &conn_opts, &connPros, NULL);
	if (MQTTREASONCODE_SUCCESS != connRsp.reasonCode) 
	{
		printf("connect fail, return code %d, %s\n", 
			connRsp.reasonCode, MQTTReasonCode_toString(connRsp.reasonCode));
		MQTTProperties_free(&connPros);
		MQTTResponse_free(connRsp);
		MQTTClient_disconnect5(client, 10000, MQTTREASONCODE_NORMAL_DISCONNECTION, NULL);
		MQTTClient_destroy(&client);
		getchar();
		exit(EXIT_FAILURE);
	}
	MQTTProperties_free(&connPros);
	MQTTResponse_free(connRsp);

#if PUBLISH_MODE
	/* build message */
	MQTTClient_message pubmsg = MQTTClient_message_initializer;
	MQTTClient_deliveryToken token;
	pubmsg.payload = (void *)PAYLOAD;
	pubmsg.payloadlen = strlen(PAYLOAD);
	pubmsg.qos = QOS;
	pubmsg.retained = 0;
	/* alias property */
	MQTTProperty topicAlias = { MQTTPROPERTY_CODE_TOPIC_ALIAS, 5 };
	MQTTProperties_add(&(pubmsg.properties), &topicAlias);

	/* publish and wait util completion */
	MQTTResponse pubRsp = MQTTClient_publishMessage5(client, TOPIC, &pubmsg, &token);
	if (MQTTREASONCODE_SUCCESS == pubRsp.reasonCode) 
	{
		rc = MQTTClient_waitForCompletion(client, token, TIMEOUT);
		printf("Message with delivery token %d delivered\n", token);
		MQTTResponse_free(pubRsp);
	}

	/* publish with empty topic */
	MQTTResponse pubRsp2 = MQTTClient_publishMessage5(client, "", &pubmsg, &token);
	if (MQTTREASONCODE_SUCCESS == pubRsp.reasonCode)
	{
		rc = MQTTClient_waitForCompletion(client, token, TIMEOUT);
		printf("Message with delivery token %d delivered\n", token);
		MQTTResponse_free(pubRsp2);
	}
	MQTTProperties_free(&(pubmsg.properties));
#else
	/* subscribe */
	MQTTResponse recvRrsp = MQTTClient_subscribe5(client, TOPIC, 0, NULL, NULL);
	if (MQTTREASONCODE_SUCCESS != recvRrsp.reasonCode) 
	{
		printf("subscribe fail, return code %d, %s\n", 
			recvRrsp.reasonCode, MQTTReasonCode_toString(recvRrsp.reasonCode));
		MQTTResponse_free(recvRrsp);
		MQTTClient_disconnect5(client, 10000, MQTTREASONCODE_NORMAL_DISCONNECTION, NULL);
		MQTTClient_destroy(&client);
		getchar();
		exit(EXIT_FAILURE);
	}
	MQTTResponse_free(recvRrsp);

	/* receive message loop */
	while (true) 
	{
		int topicLen = 0;
		char * topicName = NULL;
		MQTTClient_message * message = NULL;

		rc = MQTTClient_receive(client, &topicName, &topicLen, &message, 1000);
		if (message) 
		{
			printf("topic[%s] message[%s]\n", topicName, message->payload);
			
			MQTTClient_freeMessage(&message);
			MQTTClient_free(topicName);
		}
	}
#endif

	MQTTClient_disconnect5(client, 10000, MQTTREASONCODE_NORMAL_DISCONNECTION, NULL);
	MQTTClient_destroy(&client);
	getchar();
	return rc;
}
```

