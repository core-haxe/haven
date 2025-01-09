package zip;

import haxe.zip.Writer;
import haxe.io.BytesOutput;
import haxe.zip.Reader;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.io.Bytes;

class ZipFile {
    public var entries:List<Entry> = null;
    public var windowBits:Int = 0;

    public function new(zipBytes:Bytes = null, windowBits:Null<Int> = null) {
        if (windowBits == null) {
            #if js
            windowBits = 0;
            #else
            windowBits = -15;
            #end
        }
        this.windowBits = windowBits;
        if (zipBytes != null) {
            this.bytes = zipBytes;
        }
    }

    private var _bytes:Bytes = null;
    public var bytes(get, set):Bytes;
    private function get_bytes():Bytes {
        writeZip(); // is getting bytes meaning "write zip" a valid assumption?
        return _bytes;
    }
    private function set_bytes(value:Bytes):Bytes {
        _bytes = value;
        readZip(); // is setting bytes meaning "read zip" a valid assumption?
        return value;
    }

    public function addEntry(name:String, bytes:Bytes) {
        var entry:Entry = {
            fileName: name,
            fileSize: bytes.length,
            fileTime: Date.now(),
            compressed: false,
            dataSize: 0,
            data: bytes,
            crc32: haxe.crypto.Crc32.make(bytes)
        }
        compress(entry, 9, windowBits);
        if (entries == null) {
            entries = new List<Entry>();
        }
        entries.push(entry);
    }

    public function findEntry(name:String):Entry {
        if (entries == null) {
            return null;
        }

        for (entry in entries) {
            if (entry.fileName == name) {
                return entry;
            }
        }

        return null;
    }

    private function readZip() {
        var bytesInput = new BytesInput(_bytes);
        var reader = new Reader(bytesInput);
        entries = reader.read();
        for (entry in entries) {
            uncompress(entry, windowBits);
        }
    }

    private function writeZip() {
        var bytesOutput:BytesOutput = new BytesOutput();
        var writer = new Writer(bytesOutput);
        if (entries == null) {
            entries = new List<Entry>();
        }
        for (entry in entries) {
            compress(entry, 9, windowBits);
        }
        writer.write(entries);
        _bytes = bytesOutput.getBytes();
    }

    // helper functions since haxe doesnt suppoer compress / decompress on certain platforms (like node / browser)
    private static function compress(f:Entry, level:Int, windowBits:Int = 0) {
		if (f.compressed) {
			return;
        }

        #if js

        var deflator = new zip.pako.Deflate({level: level, windowBits: windowBits});
        deflator.push(f.data.getData(), true);
        var result = deflator.result;
        var resultBytes = Bytes.ofData(result.buffer.slice(result.byteOffset, result.byteLength + result.byteOffset));
        f.compressed = true;
        f.data = resultBytes;
        f.dataSize = f.data.length;

        #else

		// this should be optimized with a temp buffer
		// that would discard the first two bytes
		// (in order to prevent 2x mem usage for large files)
		var data = haxe.zip.Compress.run(f.data, level);
        var o = f.data.length;
		f.compressed = true;
        if (windowBits != 0) {
            f.data = data.sub(2, data.length - 6);
        } else {
            f.data = data;
        }
		f.dataSize = f.data.length;
        #end
    }

    private static function uncompress(f:Entry, windowBits:Int = 0):Bytes {
		if (!f.compressed) {
			return f.data;
        }

        #if js

        var inflator = new zip.pako.Inflate({
            windowBits: windowBits
        });
        inflator.push(f.data.getData(), true);
        var result = inflator.result;
        if (result == null) {
            throw "its null";
        }

        var resultBytes = Bytes.ofData(result.buffer.slice(result.byteOffset, result.byteLength + result.byteOffset));
		f.compressed = false;
		f.dataSize = f.fileSize;
		f.data = resultBytes;
		return f.data;

        #else

        var c = new haxe.zip.Uncompress(windowBits);
		var s = haxe.io.Bytes.alloc(f.fileSize);
		var r = c.execute(f.data, 0, s, 0);
		c.close();
		if (!r.done || r.read != f.data.length || r.write != f.fileSize)
			throw "Invalid compressed data for " + f.fileName;
		f.compressed = false;
		f.dataSize = f.fileSize;
		f.data = s;
		return f.data;

        #end
    }
}