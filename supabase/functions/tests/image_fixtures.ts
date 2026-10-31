export const png=Uint8Array.from(atob('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGM4Kqv1HwAEwwIMevLbSwAAAABJRU5ErkJggg=='),c=>c.charCodeAt(0));
function crc32(bytes:Uint8Array){let crc=0xffffffff;for(const byte of bytes){crc^=byte;for(let i=0;i<8;i++)crc=(crc>>>1)^((crc&1)?0xedb88320:0);}return (crc^0xffffffff)>>>0;}
export function paddedPng(size:number){
 const extra=size-png.length-12;if(extra<8)throw new Error('Fixture too small');
 const chunk=new Uint8Array(extra+12);new DataView(chunk.buffer).setUint32(0,extra);
 chunk.set(new TextEncoder().encode('tEXtComment\0'),4);chunk.fill(97,16,chunk.length-4);
 new DataView(chunk.buffer).setUint32(chunk.length-4,crc32(chunk.subarray(4,chunk.length-4)));
 const output=new Uint8Array(size);output.set(png.subarray(0,png.length-12));output.set(chunk,png.length-12);output.set(png.subarray(png.length-12),size-12);return output;
}
