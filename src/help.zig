const std = @import("std");

pub const IO = struct {
    
    pub fn print(writer:*std.Io.Writer,message:[]const u8)std.Io.Writer.Error!void{
    
       try writer.print("{s}\n",.{message});
    }

    // pub fn read(reader:*std.Io.Reader,message:[]const u8)std.Io.Reader.Error!void{
    //
    // }
};
