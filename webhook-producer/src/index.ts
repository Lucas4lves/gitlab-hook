import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'
import { SQSClient, SendMessageCommand, SendMessageCommandInput } from '@aws-sdk/client-sqs'

const region = process.env.REGION || "";
const client = new SQSClient({region: region});
const queueUrl = process.env.QUEUE_URL
const gitlabToken = process.env.GITLAB_TOKEN

export const handler = async ( e : APIGatewayProxyEvent ) : Promise<APIGatewayProxyResult>=> {
    const body = e.body? JSON.parse(e.body) : {}

    if(!e.headers['x-gitlab-token']){
        return {
            statusCode: 400,
            body: JSON.stringify({
                success: false,
                error: "Missing x-gitlab-token header"
            })
        }
    }


    if(!validateToken(e.headers['x-gitlab-token'])){
        return {
            statusCode: 401,
            body: JSON.stringify({
                success: false,
                error: "Unauthorized!"
            })
        }
    }

    if(!body.messageGroupId){
        return {
            statusCode: 400,
            body: JSON.stringify({
                success: false,
                error: "A messageGroupId must be sent"
            })
        }
    }

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

const validateToken = (token : string | undefined) : boolean => {
    if(token !== gitlabToken){
        return false;
    }

    return true;
}