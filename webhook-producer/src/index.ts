import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'
import { SQSClient, SendMessageCommand, SendMessageCommandInput } from '@aws-sdk/client-sqs'

export const handler = async ( e : APIGatewayProxyEvent ) : Promise<APIGatewayProxyResult>=> {
    const body = e.body? JSON.parse(e.body) : {}

    if(!body.messageGroupId){
        return {
            statusCode: 400,
            body: "ERROR: a messageGroupId must be sent"
        }
    }

    const region = process.env.REGION || "";
    const client = new SQSClient({region: region});
    const queueUrl = process.env.QUEUE_URL

    const sendMessage = async (message : string) => {
        const parameters : SendMessageCommandInput = {
            QueueUrl: queueUrl,
            MessageBody : message,
            MessageGroupId: body.messageGroupId
        }

        try{
            const cmd = new SendMessageCommand(parameters);
            const data = await client.send(cmd);

            return {
                success: true,
                data : data
            };
        }catch(err : any){
            return {
                success: false,
                error: String(err)
            }
        }
    }

    const sendMessageResult = await sendMessage(JSON.stringify(body));

    return {
        statusCode: 200,
        body: JSON.stringify(sendMessageResult)
    }
}