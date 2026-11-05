import {ImageMagick,initializeImageMagick,MagickFormat} from '@imagemagick/magick-wasm';
export class ImageInputError extends Error {constructor(public status:number,public code:string){super(code);}}
export const MAX_FILE_BYTES=5242880;
let initialized:Promise<void>|undefined;
let processing=Promise.resolve();
export async function initializeImages(){
 initialized??=Deno.readFile(new URL('./magick.wasm',import.meta.url)).then(bytes=>initializeImageMagick(bytes));
 await initialized;
}
export function imageMime(bytes:Uint8Array):'image/png'|'image/jpeg'{
 if(bytes.length>=8&&[137,80,78,71,13,10,26,10].every((value,index)=>bytes[index]===value))return 'image/png';
 if(bytes.length>=3&&bytes[0]===255&&bytes[1]===216&&bytes[2]===255)return 'image/jpeg';
 throw new ImageInputError(415,'unsupported_image');
}
export async function normalizeImage(bytes:Uint8Array,maximumOutputBytes=MAX_FILE_BYTES){
 if(bytes.length<1||bytes.length>MAX_FILE_BYTES)throw new ImageInputError(413,'file_size');
 const mime=imageMime(bytes);await initializeImages();
 let release!:()=>void;const previous=processing;processing=new Promise<void>(resolve=>release=resolve);await previous;
 try{
  return ImageMagick.read(bytes,image=>{
   try{
    image.autoOrient();image.strip();image.quality=85;
    const format=mime==='image/png'?MagickFormat.Png:MagickFormat.Jpeg;
    let result=image.write(format,data=>new Uint8Array(data));
    while(result.length>maximumOutputBytes){
     if(mime==='image/jpeg'&&image.quality>40)image.quality-=15;
     else{
      if(image.width===1&&image.height===1)throw new ImageInputError(503,'normalization_unavailable');
      image.resize(Math.max(1,Math.floor(image.width*.8)),Math.max(1,Math.floor(image.height*.8)));
     }
     image.strip();result=image.write(format,data=>new Uint8Array(data));
    }
    return {bytes:result,mime,width:image.width,height:image.height};
   }catch(error){if(error instanceof ImageInputError)throw error;throw new ImageInputError(422,'invalid_image');}
  });
 }catch(error){if(error instanceof ImageInputError)throw error;throw new ImageInputError(422,'invalid_image');}
 finally{release();}
}
