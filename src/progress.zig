const std = @import("std");
const posix = std.posix;
const linux = std.os.linux;
pub fn read_folder() !void {
    
    //Make Align Buffer from 1 to 8(struct)
    var align_buffer: [4096]u8 align(@alignOf(linux.dirent64)) = undefined;
    
    //Get CWD
    const cwd = try std.process.getCwd(&align_buffer);
    std.debug.print("Current Working Dir:{s}\n",.{cwd});
    // const cwd_null = std.mem.sliceTo(cwd,0);
    //Open Directory
    const file_descriptor = try posix.open(cwd,.{.ACCMODE = .RDONLY,.DIRECTORY = true},0);
    defer posix.close(file_descriptor);

    //Recursively Read Directory
    const entries_read = linux.getdents64(file_descriptor,&align_buffer,align_buffer.len);

    var offset:usize = 0;
    while(offset < entries_read){
        const entry = @as(*const linux.dirent64,
            @ptrCast(
                @alignCast(&align_buffer[offset])));
        
        const name = std.mem.span(@as([*:0]const u8,
                @ptrCast(&entry.name)));
        const stat = try posix.fstatat(file_descriptor,name,0);

        if (!std.mem.eql(u8,name,".") 
                    and 
            !std.mem.eql(u8,name,"..")
                    and
            !std.mem.eql(u8,name,"\\")){

            if ((stat.mode & posix.S.IFMT) == posix.S.IFREG) {
                std.debug.print("{s}*\n", .{name});
        }

        }
                      offset += entry.reclen;
    }

}
