import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from './user.service';
import { PrismaService } from 'src/prisma.service';
import { BadRequestException, NotFoundException } from '@nestjs/common';

const mockPrisma = {
  profiles: {
    findUnique: jest.fn(),
    findMany: jest.fn(),
    findFirst: jest.fn(),
    update: jest.fn(),
  },
};

describe('UserService', () => {
  let service: UserService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── getAllTutorProfile ───────────────────────────────────────────────────────

  describe('getAllTutorProfile', () => {
    it('should return all tutor profiles', async () => {
      const tutors = [
        { id: 't1', full_name: 'Alice', role: 'TUTOR' },
        { id: 't2', full_name: 'Bob', role: 'TUTOR' },
      ];
      mockPrisma.profiles.findMany.mockResolvedValue(tutors);

      const result = await service.getAllTutorProfile();

      expect(result).toEqual(tutors);
      expect(mockPrisma.profiles.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ where: { role: 'TUTOR' } }),
      );
    });

    it('should return an empty array when there are no tutors', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue([]);

      const result = await service.getAllTutorProfile();

      expect(result).toEqual([]);
    });

    it('should only select the expected profile fields', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue([]);

      await service.getAllTutorProfile();

      const callArgs = mockPrisma.profiles.findMany.mock.calls[0][0];
      expect(callArgs.select).toEqual(
        expect.objectContaining({
          id: true,
          full_name: true,
          username: true,
          avatar_url: true,
          bio: true,
          book_price: true,
          subjects: true,
          overall_rating: true,
        }),
      );
    });
  });

  // ── getAllStudentProfile ─────────────────────────────────────────────────────

  describe('getAllStudentProfile', () => {
    it('should return all student profiles', async () => {
      const students = [{ id: 's1', full_name: 'Charlie', role: 'STUDENT' }];
      mockPrisma.profiles.findMany.mockResolvedValue(students);

      const result = await service.getAllStudentProfile();

      expect(result).toEqual(students);
      expect(mockPrisma.profiles.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ where: { role: 'STUDENT' } }),
      );
    });

    it('should return an empty array when there are no students', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue([]);

      const result = await service.getAllStudentProfile();

      expect(result).toEqual([]);
    });
  });

  // ── getTutorFilteredBy ───────────────────────────────────────────────────────

  describe('getTutorFilteredBy', () => {
    const tutors = [{ id: 't1', full_name: 'Math Tutor' }];

    it('should query only for TUTOR role when no filters are given', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue(tutors);

      await service.getTutorFilteredBy();

      expect(mockPrisma.profiles.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({ role: 'TUTOR' }),
        }),
      );
    });

    it('should add OR search condition when searchQuery is provided', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue(tutors);

      await service.getTutorFilteredBy('math');

      expect(mockPrisma.profiles.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            OR: [
              { full_name: { contains: 'math', mode: 'insensitive' } },
              { username: { contains: 'math', mode: 'insensitive' } },
            ],
          }),
        }),
      );
    });

    it('should add subjects filter when subject is provided', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue(tutors);

      await service.getTutorFilteredBy(undefined, 'algebra');

      expect(mockPrisma.profiles.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            subjects: { has: 'algebra' },
          }),
        }),
      );
    });

    it('should add book_price lte filter when maxPrice is provided', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue(tutors);

      await service.getTutorFilteredBy(undefined, undefined, 150000);

      expect(mockPrisma.profiles.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            book_price: { lte: 150000 },
          }),
        }),
      );
    });

    it('should combine all filters together', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue(tutors);

      await service.getTutorFilteredBy('john', 'math', 100000);

      const callWhere = mockPrisma.profiles.findMany.mock.calls[0][0].where;
      expect(callWhere.role).toBe('TUTOR');
      expect(callWhere.OR).toBeDefined();
      expect(callWhere.subjects).toEqual({ has: 'math' });
      expect(callWhere.book_price).toEqual({ lte: 100000 });
    });

    it('should not include OR/subjects/book_price when no filters are given', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue([]);

      await service.getTutorFilteredBy();

      const callWhere = mockPrisma.profiles.findMany.mock.calls[0][0].where;
      expect(callWhere.OR).toBeUndefined();
      expect(callWhere.subjects).toBeUndefined();
      expect(callWhere.book_price).toBeUndefined();
    });

    it('should order results by created_at descending', async () => {
      mockPrisma.profiles.findMany.mockResolvedValue([]);

      await service.getTutorFilteredBy();

      expect(mockPrisma.profiles.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ orderBy: { created_at: 'desc' } }),
      );
    });
  });

  // ── getTutorDetailProfile ────────────────────────────────────────────────────

  describe('getTutorDetailProfile', () => {
    it('should return the tutor with their active offers', async () => {
      const tutor = {
        id: 't1',
        full_name: 'Alice',
        role: 'TUTOR',
        tutor_offers: [{ id: 'offer-1', title: 'Math 101', is_active: true }],
      };
      mockPrisma.profiles.findFirst.mockResolvedValue(tutor);

      const result = await service.getTutorDetailProfile('t1');

      expect(result).toEqual(tutor);
      expect(mockPrisma.profiles.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 't1', role: 'TUTOR' },
        }),
      );
    });

    it('should only query active tutor offers', async () => {
      mockPrisma.profiles.findFirst.mockResolvedValue({ id: 't1', tutor_offers: [] });

      await service.getTutorDetailProfile('t1');

      const callArgs = mockPrisma.profiles.findFirst.mock.calls[0][0];
      expect(callArgs.select.tutor_offers.where).toEqual({ is_active: true });
    });

    it('should throw NotFoundException when tutor does not exist', async () => {
      mockPrisma.profiles.findFirst.mockResolvedValue(null);

      await expect(service.getTutorDetailProfile('nonexistent-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  // ── updateProfile ────────────────────────────────────────────────────────────

  describe('updateProfile', () => {
    const existingUser = { id: 'user-1', email: 'user@example.com', role: 'STUDENT' };

    it('should update and return the updated profile', async () => {
      const updated = {
        id: 'user-1',
        email: 'user@example.com',
        full_name: 'Jane Doe',
        username: 'jane',
        bio: 'Hello',
        avatar_url: null,
        role: 'STUDENT',
      };
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      mockPrisma.profiles.update.mockResolvedValue(updated);

      const result = await service.updateProfile('user-1', {
        full_name: 'Jane Doe',
        username: 'jane',
        bio: 'Hello',
      });

      expect(result.message).toBe('Profile updated successfully!');
      expect(result.user).toEqual(updated);
    });

    it('should uppercase the role field before saving', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      mockPrisma.profiles.update.mockResolvedValue({ ...existingUser, role: 'TUTOR' });

      await service.updateProfile('user-1', { role: 'tutor' });

      expect(mockPrisma.profiles.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ role: 'TUTOR' }),
        }),
      );
    });

    it('should not include role in data if it is not provided', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      mockPrisma.profiles.update.mockResolvedValue(existingUser);

      await service.updateProfile('user-1', { username: 'jane' });

      const updateData = mockPrisma.profiles.update.mock.calls[0][0].data;
      expect(updateData.role).toBeUndefined();
    });

    it('should set updated_at to the current time on update', async () => {
      const before = new Date();
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      mockPrisma.profiles.update.mockResolvedValue(existingUser);

      await service.updateProfile('user-1', { username: 'jane' });

      const updateData = mockPrisma.profiles.update.mock.calls[0][0].data;
      expect(updateData.updated_at).toBeInstanceOf(Date);
      expect(updateData.updated_at.getTime()).toBeGreaterThanOrEqual(before.getTime());
    });

    it('should throw BadRequestException when userId is empty string', async () => {
      await expect(service.updateProfile('', {})).rejects.toThrow(BadRequestException);
      expect(mockPrisma.profiles.findUnique).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException when user does not exist', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(null);

      await expect(service.updateProfile('ghost-id', { username: 'test' })).rejects.toThrow(
        NotFoundException,
      );
      expect(mockPrisma.profiles.update).not.toHaveBeenCalled();
    });

    it('should allow partial updates without overwriting untouched fields', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      mockPrisma.profiles.update.mockResolvedValue({ ...existingUser, bio: 'New bio' });

      const result = await service.updateProfile('user-1', { bio: 'New bio' });

      expect(result.message).toBe('Profile updated successfully!');
    });
  });
});
