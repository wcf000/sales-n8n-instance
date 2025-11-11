import {
  IExecuteFunctions,
  INodeExecutionData,
  INodeType,
  INodeTypeDescription,
} from 'n8n-workflow';

export class ExampleNode implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'Example Node',
    name: 'exampleNode',
    icon: 'fa:code',
    group: ['transform'],
    version: 1,
    description: 'Example custom node for n8n',
    defaults: {
      name: 'Example Node',
    },
    inputs: ['main'],
    outputs: ['main'],
    properties: [
      {
        displayName: 'Operation',
        name: 'operation',
        type: 'options',
        options: [
          {
            name: 'Process Data',
            value: 'process',
          },
          {
            name: 'Transform Data',
            value: 'transform',
          },
        ],
        default: 'process',
        description: 'Operation to perform',
      },
      {
        displayName: 'Input Field',
        name: 'inputField',
        type: 'string',
        default: '',
        placeholder: 'Enter field name',
        description: 'Name of the input field to process',
      },
      {
        displayName: 'Output Field',
        name: 'outputField',
        type: 'string',
        default: 'output',
        placeholder: 'Enter field name',
        description: 'Name of the output field',
      },
    ],
  };

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData();
    const returnData: INodeExecutionData[] = [];

    for (let i = 0; i < items.length; i++) {
      const operation = this.getNodeParameter('operation', i) as string;
      const inputField = this.getNodeParameter('inputField', i) as string;
      const outputField = this.getNodeParameter('outputField', i) as string;

      const inputData = items[i].json[inputField] || items[i].json;

      let processedData: any;

      if (operation === 'process') {
        processedData = {
          [outputField]: {
            original: inputData,
            processed: `Processed: ${JSON.stringify(inputData)}`,
            timestamp: new Date().toISOString(),
          },
        };
      } else if (operation === 'transform') {
        processedData = {
          [outputField]: {
            transformed: typeof inputData === 'string' 
              ? inputData.toUpperCase() 
              : JSON.stringify(inputData).toUpperCase(),
            length: typeof inputData === 'string' 
              ? inputData.length 
              : JSON.stringify(inputData).length,
          },
        };
      }

      returnData.push({
        json: {
          ...items[i].json,
          ...processedData,
        },
      });
    }

    return [returnData];
  }
}

