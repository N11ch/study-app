import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateProfileDTO } from './dto/update-profile.dto';
import { AuthGuard } from '@nestjs/passport';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('tutors/all')
  async getAllProfile() {
    return this.userService.getAllTutorProfile();
  }

  @Get('student')
  async getStudentProfile() {
    return this.userService.getAllStudentProfile();
  }

  //  GET /user/tutors?search=math&maxPrice=150000
  @Get('tutors')
  async getTutorList(
    @Query('search') search?: string,
    @Query('subject') subject?: string,
    @Query('maxPrice') maxPrice?: string,
  ) {
    const parsedPrice = maxPrice ? parseFloat(maxPrice) : undefined;
    return this.userService.getTutorFilteredBy(search, subject, parsedPrice);
  }

  // GET /user/tutors/1234-abcd-5678
  @Get('tutor/:id')
  async getTutorDetail(@Param('id') id: string) {
    return this.userService.getTutorDetailProfile(id);
  }

  // @UseGuards(AuthGuard('jwt'))
  // @Patch('update/profile')
  // async updateProfile(@Body() body: any) {
  //   return this.userService.updateProfile(body.userId, {
  //     full_name: body.full_name,
  //   });
  // }

  @Get()
  async getDummyData() {
    return {
      message: 'This is a dummy response from the UserController.',
      timestamp: new Date(),
    };
  }
}
