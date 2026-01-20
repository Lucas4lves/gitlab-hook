import { SQSEvent, SQSHandler, Context } from 'aws-lambda'

export const handler : SQSHandler = async ( event : SQSEvent, context : Context ) : Promise<void> => {
    for (const record of event.Records){
        const payload = record.body;

        console.log("Payload: ", payload);
    }
}