import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma.service';
import { UpdateProfileDTO } from './dto/update-profile.dto';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async getAllTutorProfile() {
    return this.prisma.profiles.findMany({
      where: {
        role: 'TUTOR',
      },

      select: {
        id: true,
        full_name: true,
        username: true,
        avatar_url: true,
        bio: true,
        book_price: true,
        subjects: true,
        overall_rating: true,
        rating_count: true,
        tutor_rating: true,
      },
    });
  }

  async getAllStudentProfile() {
    return this.prisma.profiles.findMany({
      where: {
        role: 'STUDENT',
      },

      select: {
        id: true,
        full_name: true,
        username: true,
        avatar_url: true,
        bio: true,
        student_rating: true,
      },
    });
  }

  async getTutorFilteredBy(
    searchQuery?: string,
    subject?: string,
    maxPrice?: number,
  ) {
    return this.prisma.profiles.findMany({
      where: {
        role: 'TUTOR',

        // filter by search query
        ...(searchQuery && {
          OR: [
            { full_name: { contains: searchQuery, mode: 'insensitive' } },
            { username: { contains: searchQuery, mode: 'insensitive' } },
          ],
        }),

        // filter by subject
        ...(subject && {
          subjects: { has: subject },
        }),

        // filter by maximum prices
        ...(maxPrice && {
          book_price: { lte: maxPrice },
        }),
      },

      select: {
        id: true,
        full_name: true,
        username: true,
        avatar_url: true,
        bio: true,
        book_price: true,
        subjects: true,
      },
      orderBy: { created_at: 'desc' },
    });
  }

  async getTutorDetailProfile(tutorID: string) {
    const tutor = await this.prisma.profiles.findFirst({
      where: {
        id: tutorID,
        role: 'TUTOR',
      },

      select: {
        id: true,
        full_name: true,
        username: true,
        avatar_url: true,
        bio: true,
        book_price: true,
        subjects: true,
        overall_rating: true,
        tutor_rating: true,

        tutor_offers: {
          where: { is_active: true },
          select: {
            id: true,
            title: true,
            summary: true,
            price_per_hour: true,
            duration_minutes: true,
          },
        },
      },
    });
    if (!tutor) {
      throw new NotFoundException('The tutor that you find is not found');
    }

    return tutor;
  }

  async updateProfile(userId: string, data: UpdateProfileDTO) {
    if (!userId) {
      throw new BadRequestException('User ID is required');
    }

    const user = await this.prisma.profiles.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found.');
    }

    console.log('data in DTO ', data);

    const updateUserProfile = await this.prisma.profiles.update({
      where: { id: userId },
      data: {
        full_name: data.full_name,
        username: data.username,
        bio: data.bio,
        avatar_url: data.avatar_url,
        ...(data.role && { role: data.role.toUpperCase() }),
        updated_at: new Date(),
      },

      select: {
        id: true,
        email: true,
        full_name: true,
        username: true,
        bio: true,
        avatar_url: true,
        role: true,
      },
    });

    console.log('updated user data in database: ', updateUserProfile);

    return {
      message: 'Profile updated successfully!',
      user: updateUserProfile,
    };
  }
}
